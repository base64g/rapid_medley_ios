//
//  cpp.cpp
//  cpptest
//
//  Created by base64 on 2017/05/15.
//  Copyright © 2017年 basemusi. All rights reserved.
//
#include "algorithmfactory.h"
#include "essentiamath.h"
#include "pool.h"
#include <iostream>
#include <algorithm>
#include <stdlib.h>
#include "cpp.hpp"

using namespace std;
using namespace essentia;
using namespace standard;

float* Cpp::scale(float* input, const int size){
    /////// PARAMS //////////////
    int framesize = 2048;
    int hopsize = 512;
    int sr = 44100;
    
    // register the algorithms in the factory(ies)
    essentia::init();
    
    // instanciate factory
    AlgorithmFactory& factory = AlgorithmFactory::instance();
    
    // audio loader (we always need it...)
    
    
    vector<Real> audio;
    for(int i=0;i<size;i++){
        audio.push_back(input[i]);
    }
    
    
    // create algorithms
    Algorithm* pitchDetect = factory.create("PredominantPitchMelodia",
                                            "sampleRate", sr, "hopSize", hopsize, "frameSize", framesize);
    
    
    // configure pitch detection
    vector<Real> pitch, pitchConfidence;
    pitchDetect->input("signal").set(audio);
    pitchDetect->output("pitch").set(pitch);
    pitchDetect->output("pitchConfidence").set(pitchConfidence);
    
    
    // process:
    // extract predominant melody using the MELODIA algorithm
    pitchDetect->compute();
    
    // clean up
    delete pitchDetect;
    
    // shut down essentia
    essentia::shutdown();
    float *ret = (float *)malloc((size/hopsize - 1)*sizeof(float));
    for(int i=0;i<size/hopsize - 1; i++){
        if(pitchConfidence[i]>0)
            ret[i] = pitch[i];
        else
            ret[i] = 0;
    }
    return ret;
    
}



int* Cpp::beats(float* input, const int size){

    // register the algorithms in the factory(ies)
    essentia::init();
    
    Pool pool;
    
    /////// PARAMS //////////////
    Real sampleRate = 44100.0;
    
    AlgorithmFactory& factory = AlgorithmFactory::instance();
    
    Algorithm* beatTracker = factory.create("BeatTrackerMultiFeature",
                                            "maxTempo", 240,
                                            "minTempo", 120);
    
    
    vector<Real> audio;
    for(int i=0;i<size;i++){
        audio.push_back(*input);
        input++;
    }
    
    vector<Real> beats;
    Real confidence;
    
    beatTracker->input("signal").set(audio);
    beatTracker->output("ticks").set(beats);
    beatTracker->output("confidence").set(confidence);
    beatTracker->compute();
    
    delete beatTracker;
    
    essentia::shutdown();
    const int length = beats.size()+1;
    int *ret = (int *)malloc(length*sizeof(int));
    for(int i=0;i<length-1; i++){
        ret[i] = (int)(beats[i] * 44100);
    }
    ret[length-1]=-1;
    return ret;
    
}
