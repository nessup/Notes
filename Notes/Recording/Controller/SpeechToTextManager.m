//
//  SpeechToTextManager.m
//  Notes
//
//  Created by Dany on 5/29/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "SpeechToTextManager.h"
#import "Utility.h"

#include <FLAC/all.h>
#import "JSONKit.h"
#import "wav.h"

#define BUFFSIZE (1 << 16)

NSString *const SpeechToTextManagerStateChanged = @"SpeechToTextManagerStateChanged";

/**
 * BUFFSIZE samples * 2 bytes per sample * 2 channels
 */
static FLAC__byte buffer[BUFFSIZE * 2 * 2];
/**
 * BUFFSIZE samples * 2 channels
 */
static FLAC__int32 pcm[BUFFSIZE * 2];

@interface SpeechToTextManager () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic, readwrite, strong) NSURL *soundFileURL;

@end

@implementation SpeechToTextManager {
    AVAudioRecorder *_recorder;
    AVAudioPlayer *_player;
    NSOperationQueue *_operationQueue;

    NSString *_currentTranscriptionText;
    void (^_currentTranscriptionCompletionBlock)(NSString *, NSData *);
    NSString *_currentAACPath;
}

+ (SpeechToTextManager *)sharedInstance {
    static SpeechToTextManager *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];

    if( self ) {
        _operationQueue = [NSOperationQueue new];



        NSDictionary *recordSettings = @{
            AVFormatIDKey: @(kAudioFormatLinearPCM),
            AVLinearPCMBitDepthKey: @16,
            AVLinearPCMIsBigEndianKey: @NO,
            AVSampleRateKey: @44100,
            AVNumberOfChannelsKey: @2,
            AVLinearPCMIsNonInterleaved: @YES,
            AVLinearPCMIsFloatKey: @YES
        };

        NSError *error = nil;

        _recorder = [[AVAudioRecorder alloc]
                     initWithURL:self.soundFileURL
                        settings:recordSettings
                           error:&error];

        if( error ) {
            NSLog(@"error: %@", [error localizedDescription]);
        }
        else {
            [_recorder prepareToRecord];
        }
    }

    return self;
}

- (NSURL *)soundFileURL {
    if( _soundFileURL ) {
        return _soundFileURL;
    }

    NSArray *dirPaths;
    NSString *docsDir;

    dirPaths = NSSearchPathForDirectoriesInDomains(
            NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *soundFilePath = [docsDir
                               stringByAppendingPathComponent:@"sound.wav"];

    _soundFileURL = [NSURL fileURLWithPath:soundFilePath];

    return _soundFileURL;
}

#pragma mark - State management

- (void)setState:(SpeechToTextManagerState)state {
    if( _state == state ) {
        return;
    }

    _state = state;

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SpeechToTextManagerStateChanged object:nil];
    });
}

#pragma mark - Recording and playback

- (void)startRecording {
    if( !_player.playing ) {
        if( [_recorder record] ) {
            self.state &= ~SpeechToTextManagerStateError;
            self.state |= SpeechToTextManagerStateRecording;
        }
    }
}

- (void)startPlaying {
    if( !_recorder.recording ) {
        NSError *error;

        _player = [[AVAudioPlayer alloc]
                   initWithContentsOfURL:_recorder.url
                                   error:&error];

        _player.delegate = self;

        if( error ) {
            NSLog(@"Error: %@",
                  [error localizedDescription]);
        }
        else {
            if( [_player play] ) {
                self.state |= SpeechToTextManagerStatePlaying;
            }
        }
    }
}

- (void)stop {
    if( _recorder.recording ) {
        [_recorder stop];
        self.state &= ~SpeechToTextManagerStateRecording;
    }
    else if( _player.playing ) {
        [_player stop];
        self.state &= ~SpeechToTextManagerStatePlaying;
    }
}

#pragma mark - Recognition

- (void)getText:(void (^)(NSString *, NSData *))completion {
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(getTextMain:) object:completion];

    [_operationQueue addOperation:operation];
}

- (void)getTextMain:(void (^)(NSString *, NSData *))completion {
    self.state |= SpeechToTextManagerStateTranscribing;

    NSString *wavPath = [_recorder.url path];
    NSString *flacPath = [[ApplicationDocumentsDirectory() path] stringByAppendingPathComponent:@"out.flac"];

    [self convertWAV:wavPath toFLAC:flacPath];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com/speech-api/v1/recognize?xjerr=1&client=chromium&lang=en-US"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"audio/x-flac; rate=44100" forHTTPHeaderField:@"Content-Type"];
    NSData *flacData = [NSData dataWithContentsOfFile:flacPath];
    [request setHTTPBody:flacData];
    NSURLResponse *response = nil;
    request.timeoutInterval = 5.f;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSString *respStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSDictionary *respDict = [respStr objectFromJSONString];
    NSArray *hypotheses = respDict[@"hypotheses"];
    NSString *text = nil;
    void (^executeCompletion)(NSString *, NSData *) = ^(NSString *transcription, NSData *audio) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            completion(transcription, audio);
        });
    };

    if( hypotheses.count ) {
        text = [hypotheses[0] valueForKey:@"utterance"];

        if( completion ) {
            executeCompletion(text, [NSData dataWithContentsOfFile:wavPath]);
        }
    }
    else {
        self.state |= SpeechToTextManagerStateError;

        if( completion ) {
            executeCompletion(nil, nil);
        }
    }

    if( _operationQueue.operations.count == 1 ) {
        self.state &= ~SpeechToTextManagerStateTranscribing;
    }
}

- (BOOL)convertWAV:(NSString *)wavPath toFLAC:(NSString *)flacPath {
    FLAC__StreamEncoder *encoder;
    FILE *infile;
    char *data_location;
    uint32_t sample_rate;
    uint32_t total_samples;
    uint32_t channels;
    uint32_t bits_per_sample;
    uint32_t data_offset;
    int err;
    const char *wavfile = [wavPath cStringUsingEncoding:NSUTF8StringEncoding];
    const char *flacfile = [flacPath cStringUsingEncoding:NSUTF8StringEncoding];

    if( !wavfile || !flacfile ) {
        return NO;
    }

    /**
     * Remove the original file, if present, in order
     * not to leave chunks of old data inside
     */
    remove(flacfile);

    /**
     * Read the first 64kB of the file. This somewhat guarantees
     * that we will find the beginning of the data section, even
     * if the WAV header is non-standard and contains
     * other garbage before the data (NB Apple's 4kB FLLR section!)
     */
    infile = fopen(wavfile, "rb");

    if( !infile ) {
        return NO;
    }

    fread(buffer, BUFFSIZE, 1, infile);

    /**
     * Search the offset of the data section
     */
    data_location = memstr((char *)buffer, "data", BUFFSIZE);

    if( !data_location ) {
        fclose(infile);
        return NO;
    }

    data_offset = data_location - (char *)buffer;

    /**
     * For an explanation on why the 4 + 4 byte extra offset is there,
     * see the comment for calculating the number of total_samples.
     */
    fseek(infile, data_offset + 4 + 4, SEEK_SET);

    struct sprec_wav_header *hdr = sprec_wav_header_from_data((char *)buffer);

    if( !hdr ) {
        fclose(infile);
        return NO;
    }

    /**
     * Sample rate must be between 16000 and 44000
     * for the Google Speech APIs.
     * There should be two channels.
     * Sample depth is 16 bit signed, little endian.
     */
    sample_rate = hdr->sample_rate;
    channels = hdr->number_of_channels;
    bits_per_sample = hdr->bits_per_sample;

    /**
     * hdr->file_size contains actual file size - 8 bytes.
     * the eight bytes at position `data_offset' are:
     * 'data' then a 32-bit unsigned int, representing
     * the length of the data section.
     */
    total_samples = ((hdr->file_size + 8) - (data_offset + 4 + 4)) / (channels * bits_per_sample / 8);

    /**
     * Create and initialize the FLAC encoder
     */
    encoder = FLAC__stream_encoder_new();

    if( !encoder ) {
        fclose(infile);
        free(hdr);
        return NO;
    }

    FLAC__stream_encoder_set_verify(encoder, true);
    FLAC__stream_encoder_set_compression_level(encoder, 5);
    FLAC__stream_encoder_set_channels(encoder, channels);
    FLAC__stream_encoder_set_bits_per_sample(encoder, bits_per_sample);
    FLAC__stream_encoder_set_sample_rate(encoder, sample_rate);
    FLAC__stream_encoder_set_total_samples_estimate(encoder, total_samples);

    err = FLAC__stream_encoder_init_file(encoder, flacfile, NULL, NULL);

    if( err ) {
        fclose(infile);
        free(hdr);
        FLAC__stream_encoder_delete(encoder);
        return NO;
    }

    /**
     * Feed the PCM data to the encoder in 64kB chunks
     */
    size_t left = total_samples;

    while( left > 0 ) {
        size_t need = left > BUFFSIZE ? BUFFSIZE : left;
        fread(buffer, channels * bits_per_sample / 8, need, infile);

        size_t i;

        for( i = 0; i < need * channels; i++ ) {
            if( bits_per_sample == 16 ) {
                /**
                 * 16 bps, signed little endian
                 */
                pcm[i] = *(int16_t *)(buffer + i * 2);
            }
            else {
                /**
                 * 8 bps, unsigned
                 */
                pcm[i] = *(uint8_t *)(buffer + i);
            }
        }

        FLAC__bool succ = FLAC__stream_encoder_process_interleaved(encoder, pcm, need);

        if( !succ ) {
            fclose(infile);
            free(hdr);
            FLAC__stream_encoder_delete(encoder);
            return NO;
        }

        left -= need;
    }

    /**
     * Write out/finalize the file
     */
    FLAC__stream_encoder_finish(encoder);

    /**
     * Clean up
     */
    FLAC__stream_encoder_delete(encoder);
    fclose(infile);
    free(hdr);

    return YES;
}

#pragma mark - AVAudioRecorder delegate

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder {
    self.state |= SpeechToTextManagerStateInterrupted;
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags {
    self.state &= ~SpeechToTextManagerStateInterrupted;
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    self.state &= ~SpeechToTextManagerStateRecording;
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    self.state &= ~SpeechToTextManagerStateRecording;
}

#pragma mark - AVAudioPlayer delegate

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    self.state |= SpeechToTextManagerStateInterrupted;
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags {
    self.state &= ~SpeechToTextManagerStateInterrupted;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.state &= ~SpeechToTextManagerStatePlaying;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    self.state &= ~SpeechToTextManagerStatePlaying;
}

#pragma mark - Utility

char *memstr(char *haystack, char *needle, int size) {
    char *p;
    char needlesize = strlen(needle);

    for( p = haystack; p <= haystack - needlesize + size; p++ ) {
        if( memcmp(p, needle, needlesize) == 0 ) {
            /**
             * Found it
             */
            return p;
        }
    }

    /**
     * Not found
     */
    return NULL;
}

struct sprec_wav_header *sprec_wav_header_from_data(const char *ptr) {
    struct sprec_wav_header *hdr;

    hdr = malloc(sizeof(*hdr));

    if( !hdr ) {
        return NULL;
    }

    /**
     * We could use __attribute__((__packed__)) and a single memcpy(),
     * but we choose this approach for the sake of portability.
     */
    memcpy(&hdr->RIFF_marker, ptr + 0, 4);
    memcpy(&hdr->file_size, ptr + 4, 4);
    memcpy(&hdr->filetype_header, ptr + 8, 4);
    memcpy(&hdr->format_marker, ptr + 12, 4);
    memcpy(&hdr->data_header_length, ptr + 16, 4);
    memcpy(&hdr->format_type, ptr + 20, 2);
    memcpy(&hdr->number_of_channels, ptr + 22, 2);
    memcpy(&hdr->sample_rate, ptr + 24, 4);
    memcpy(&hdr->bytes_per_second, ptr + 28, 4);
    memcpy(&hdr->bytes_per_frame, ptr + 32, 2);
    memcpy(&hdr->bits_per_sample, ptr + 34, 2);

    return hdr;
}

@end
