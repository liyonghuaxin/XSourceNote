//
//  XSourceNoteFormatter.m
//  XSourceNote
//
//  Created by everettjf on 16/3/9.
//  Copyright © 2016年 everettjf. All rights reserved.
//

#import "XSourceNoteFormatter.h"
#import "XSourceNoteStorage.h"
#import "XSourceNoteDefaults.h"

@implementation XSourceNoteFormatter

+ (XSourceNoteFormatter *)sharedFormatter{
    static XSourceNoteFormatter *inst;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = [[XSourceNoteFormatter alloc]init];
    });
    return inst;
}

- (BOOL)saveTo:(NSString *)filePath{
    XSourceNoteDefaults *def = [XSourceNoteDefaults sharedDefaults];
    XSourceNoteStorage *st = [XSourceNoteStorage sharedStorage];
    
    NSMutableString *content = [[NSMutableString alloc]init];
    
    [content appendString:@"\n\n"];
    [content appendFormat:@"# Basic Information\n"];
    [content appendFormat:@" - Name : %@\n", st.projectName];
    [content appendFormat:@" - Site : %@\n", st.projectSite];
    [content appendFormat:@" - Repo : %@\n", st.projectRepo];
    [content appendFormat:@" - Revision : %@\n", st.projectRevision];
    [content appendFormat:@" - Description : \n"];
    [content appendString: st.projectDescription];
    [content appendString:@"\n"];
    
    [content appendString:@"\n\n"];
    [content appendFormat:@"# Global Note\n"];
    [content appendString:st.projectNote];
    
    
    [content appendString:@"\n\n"];
    [content appendString:@"# File Notes\n"];
    NSArray *notes = [st fetchAllLineNotes];
    [notes enumerateObjectsUsingBlock:^(XSNote *  _Nonnull n, NSUInteger idx, BOOL * _Nonnull stop) {
        [content appendFormat:@"%@. %@\n",@(idx), n.source];
        [content appendFormat:@" - Line : %@ - %@\n", n.begin, n.end];
        [content appendFormat:@" - Note : \n"];
        
        // Code block
        if(n.code){
            [content appendString:@"\n"];
            if([def.codeStyle isEqual:@0]){
                [content appendString:@"```\n"];
                [content appendString:n.code];
                [content appendString:@"```\n"];
            }else{
                [content appendString:@"{% highlight c %}\n"];
                [content appendString:n.code];
                [content appendString:@"{% endhighlight %}\n"];
            }
            [content appendString:@"\n"];
        }
        
        [content appendFormat:@"\n%@\n",n.content];
        [content appendString:@"\n"];
    }];
    
    [content appendString:@"\n\n"];
    [content appendFormat:@"# Summarize\n"];
    [content appendString:st.projectSummarize];
    
    [content appendString:@"\n\n"];
    [content appendString:@"\n\n"];
    [content appendFormat:@"---\n"];
    [content appendFormat:@"*Generated by XSourceNote at %@*\n", [NSDate date]];
    
    
    NSError *error;
    if(![content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error]){
        return NO;
    }
    
    return YES;
}

@end
