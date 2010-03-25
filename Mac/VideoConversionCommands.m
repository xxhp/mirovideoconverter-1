/* -*- mode: objc -*- */
//
//  VideoConversionComands.m
//  Miro Video Converter
//
//  Created by C Worth on 2/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VideoConversionCommands.h"
#import <Cocoa/Cocoa.h>

@implementation VideoConversionCommands
@synthesize screenSize;

char *deviceNames[] = { "Android Devices", " Nexus One", " Dream / G1", " Magic / myTouch", " Droid", " Eris / Desire", " Hero", " Cliq / DEXT", " Behold II", nil, "Apple Devices", " iPhone", " iPod Touch", " iPod Nano", " iPod Classic", nil, "Other Devices and Formats", " Playstation Portable (PSP)", " Theora", " MP4", " MP3 (Audio only)", nil, nil };
char *selectors[] = { "Android Devices", "nexus", "dream", "magic", "droid", "eris", "hero", "cliq", "behold", nil, "Apple Devices", "ipod", "ipod", "ipod", "ipod", nil, "Other Devices", "playstation", "theora", "mp4", "mp3", nil, nil };
char *fileExtensions[] = { "Android Devices", "nexus.mp4", "dream.mp4", "magic.mp4", "droid.mp4", "eris.mp4", "hero.mp4", "cliq.mp4", "behold.mp4", nil, "Apple Devices", "iphone.mp4", "ipod.mp4", "ipod.mp4", "ipod.mp4", nil, "Other Devices", "psp.mp4", "theora.ogv", "mp4", "mp3", nil, nil };
char *converterExecutables[] = { "Android Devices", "ffmpeg", "ffmpeg", "ffmpeg", "ffmpeg", "ffmpeg", "ffmpeg", "ffmpeg", "ffmpeg", nil, "Apple Devices", "ffmpeg", "ffmpeg", "ffmpeg", "ffmpeg", nil, "Other Devices", "ffmpeg", "ffmpeg2theora", "ffmpeg", "ffmpeg", nil, nil };
CGSize screenSizes[] = { { 0,0 }, { 800,480 }, { 480,320 }, { 480,320 }, { 854,480 }, { 480,320 }, { 480,320 }, { 480,320 }, { 480,320 }, { 0,0 }, { 0,0 }, { 480,320 },  { 480,320 }, { 480,320 }, { 480,320 }, { 0,0 }, { 0,0 }, { 480,320 },  { 1024,768 }, { 1024,768 }, { 1024,768 }, { 0,0 }, { 0,0 } };

-(int) deviceIndex:(NSString *)device {
  int i; BOOL lastNull;
  for(i=0, lastNull=0;;i++){
    if(lastNull && !deviceNames[i]){
      i=-1;
      break;
    }
    else if(!deviceNames[i])
      lastNull = 1;
    else {
      lastNull = 0;
      if(![device compare:[NSString stringWithFormat:@"%s",deviceNames[i]]])
        break;
    }
  }
  return i;
}

-(NSString *) outputVideoSizeForDevice:(NSString *)device {
  int index;
  CGSize size;
  if(device==nil)
    return nil;
  index = [self deviceIndex:device];
  if(screenSize.width == 0 || screenSize.height == 0)
    size = screenSizes[index];
  else
    size = screenSize;
  return [NSString stringWithFormat:@"%ix%i",(int)size.width,(int)size.height];
}

-(NSString *) fFMPEGLaunchPathForDevice:(NSString *)device {
  int index;
  //format query
  if(device == nil)
    index = 1;
  else
    index = [self deviceIndex:device];
  if(index==-1)
    return nil;
  else {
    NSString *s = [NSString stringWithFormat:@"%s",converterExecutables[index]];
    return [[NSBundle mainBundle]
             pathForResource:s ofType:@""];
  }
}

-(NSString *) fFMPEGOutputFileForFile:(NSString *)inputFile andDevice:(NSString *)device {
  int index;
  // format query
  if(device==nil)
    return nil;
  else
    index = [self deviceIndex:device];
  if(index==-1)
    return nil;
  else {
    NSString *newExtension = [NSString stringWithFormat:@"%s",fileExtensions[index]];
    // If the new extension is the same as the old, would overwrite file, so in this case
    // append
    if([inputFile pathExtension] && ![[inputFile pathExtension] compare:newExtension])
      return [inputFile stringByAppendingPathExtension:newExtension];
    else
      return [[inputFile stringByDeletingPathExtension]
               stringByAppendingPathExtension:newExtension];
  }
}

-(NSArray *) fFMPEGArgumentsForFile:(NSString *)file andDevice:(NSString *)device {
  int index;
  //format query
  if(device==nil)
    return [self formatQueryArgsForFile:(NSString *)file];
  else
    index = [self deviceIndex:device];
  if(index==-1)
    return nil;
  else {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:
                                         @"%sArgsForFile:andDevice:",selectors[index]]);
    NSArray* (*fn)(id, SEL, NSString*, NSString*);
    fn = (NSArray* (*)(id, SEL, NSString*, NSString*))[self methodForSelector:selector];
    NSArray *args = fn(self, selector, file, device);
    return args;
  }
}

-(NSArray *)formatQueryArgsForFile:(NSString *)file {
  NSMutableArray *args = [NSMutableArray arrayWithCapacity:0];
  [args addObject:@"-i"];
  [args addObject:file];
  return [NSArray arrayWithArray:args];
}

-(NSArray *) nexusArgsForFile:(NSString *)file andDevice:(NSString *)device {
  NSMutableArray *args = [NSMutableArray arrayWithCapacity:0];
  [args addObject:@"-i"];
  [args addObject:file];
  [args addObject:@"-y"];
  [args addObject:@"-f"];
  [args addObject:@"mp4"];
  [args addObject:@"-vcodec"];
  [args addObject:@"mpeg4"];
  [args addObject:@"-sameq"];
  [args addObject:@"-acodec"];
  [args addObject:@"aac"];
  [args addObject:@"-ab"];
  [args addObject:@"48000"];
  [args addObject:@"-r"];
  [args addObject:@"18"];
  [args addObject:@"-s"];
  [args addObject:[self outputVideoSizeForDevice:device]];
  [args addObject:[self fFMPEGOutputFileForFile:file andDevice:device]];
  return [NSArray arrayWithArray:args];
}

-(NSArray *) dreamArgsForFile:(NSString *)file andDevice:(NSString *)device {
  return [self nexusArgsForFile:file andDevice:device];
}

-(NSArray *) magicArgsForFile:(NSString *)file andDevice:(NSString *)device {
  return [self nexusArgsForFile:file andDevice:device];
}

-(NSArray *) droidArgsForFile:(NSString *)file andDevice:(NSString *)device {
  return [self nexusArgsForFile:file andDevice:device];
}

-(NSArray *) erisArgsForFile:(NSString *)file andDevice:(NSString *)device {
  return [self nexusArgsForFile:file andDevice:device];
}

-(NSArray *) heroArgsForFile:(NSString *)file andDevice:(NSString *)device {
  return [self nexusArgsForFile:file andDevice:device];
}

-(NSArray *) cliqArgsForFile:(NSString *)file andDevice:(NSString *)device {
  return [self nexusArgsForFile:file andDevice:device];
}

-(NSArray *) beholdArgsForFile:(NSString *)file andDevice:(NSString *)device {
  return [self nexusArgsForFile:file andDevice:device];
}

-(NSArray *) iPhoneArgsForFile:(NSString *)file andDevice:(NSString *)device {
  NSMutableArray *args = [NSMutableArray arrayWithCapacity:0];
  [args addObject:@"-i"];
  [args addObject:file];
  [args addObject:@"-vcodec"];
  [args addObject:@"mpeg4"];
  [args addObject:@"-b"];
  [args addObject:@"1200kb"];
  [args addObject:@"-mbd"];
  [args addObject:@"2"];
  [args addObject:@"-cmp"];
  [args addObject:@"2"];
  [args addObject:@"-subcmp"];
  [args addObject:@"2"];
  [args addObject:@"-r"];
  [args addObject:@"20"];
  [args addObject:@"-acodec"];
  [args addObject:@"aac"];
  [args addObject:@"-ab"];
  [args addObject:@"96000"];
  [args addObject:@"-s"];
  [args addObject:[self outputVideoSizeForDevice:device]];
  [args addObject:[self fFMPEGOutputFileForFile:file andDevice:device]];
  return [NSArray arrayWithArray:args];
}

-(NSArray *) ipodArgsForFile:(NSString *)file andDevice:(NSString *)device {
  return [self iPhoneArgsForFile:file andDevice:device];
}

-(NSArray *) playstationArgsForFile:(NSString *)file andDevice:(NSString *)device {
  NSMutableArray *args = [NSMutableArray arrayWithCapacity:0];
  [args addObject:@"-i"];
  [args addObject:file];
  [args addObject:@"-b"];
  [args addObject:@"512000"];
  [args addObject:@"-ar"];
  [args addObject:@"24000"];
  [args addObject:@"-ab"];
  [args addObject:@"64000"];
  [args addObject:@"-f"];
  [args addObject:@"psp"];
  [args addObject:@"-r"];
  [args addObject:@"29.97"];
  [args addObject:@"-s"];
  [args addObject:[self outputVideoSizeForDevice:device]];
  [args addObject:[self fFMPEGOutputFileForFile:file andDevice:device]];
  return [NSArray arrayWithArray:args];
}

-(NSArray *) theoraArgsForFile:(NSString *)file andDevice:(NSString *)device {
  NSMutableArray *args = [NSMutableArray arrayWithCapacity:0];
  [args addObject:file];
  [args addObject:@"--videoquality"];
  [args addObject:@"8"];
  [args addObject:@"--audioquality"];
  [args addObject:@"6"];
  [args addObject:@"--frontend"];
  [args addObject:@"-o"];
  [args addObject:[self fFMPEGOutputFileForFile:file andDevice:device]];
  return [NSArray arrayWithArray:args];
}

-(NSArray *) mp4ArgsForFile:(NSString *)file andDevice:(NSString *)device {
  NSMutableArray *args = [NSMutableArray arrayWithCapacity:0];
  [args addObject:@"-i"];
  [args addObject:file];
  [args addObject:@"-f"];
  [args addObject:@"mp4"];
  [args addObject:@"-vcodec"];
  [args addObject:@"mpeg4"];
  [args addObject:@"-sameq"];
  [args addObject:@"-r"];
  [args addObject:@"20"];
  [args addObject:[self fFMPEGOutputFileForFile:file andDevice:device]];
  return [NSArray arrayWithArray:args];
}

-(NSArray *) mp3ArgsForFile:(NSString *)file andDevice:(NSString *)device {
  NSMutableArray *args = [NSMutableArray arrayWithCapacity:0];
  [args addObject:@"-i"];
  [args addObject:file];
  [args addObject:@"-f"];
  [args addObject:@"mp3"];
  [args addObject:@"-y"];
  [args addObject:@"-acodec"];
  [args addObject:@"ac3"];
  [args addObject:[self fFMPEGOutputFileForFile:file andDevice:device]];
  return [NSArray arrayWithArray:args];
}

//-(NSArray *) templateArgsForFile:(NSString *)file andDevice:(NSString *)device {
//  NSMutableArray *args = [NSMutableArray arrayWithCapacity:0];
//  [args addObject:@"-i"];
//  [args addObject:file];
// START: Start input arg string here (eg START: -y -fpre -aspect 3:2... ), put trailing space on end
//
// END:
//  [args addObject:[self fFMPEGOutputFileForFile:file andDevice:device]];
//  return [NSArray arrayWithArray:args];
//}

@end
