#!/bin/bash
cd ~
if ! [[ -L dev ]]; then sudo ln -s Documents/dev .; fi
#if ! [[ -L Documents ]]; then sudo mv Documents/ Documents-old && sudo ln -s Documents .; fi
if ! [[ -L Downloads ]]; then sudo mv Downloads/ Downloads-old && sudo ln -s Downloads .; fi
#if ! [[ -L Movies ]]; then sudo mv Movies/ Movies-old && sudo ln -s Movies .; fi
#if ! [[ -L Music ]]; then sudo mv Music/ Music-old && sudo ln -s Music .; fi
#if ! [[ -L Pictures ]]; then sudo mv Pictures/ Pictures-old && sudo ln -s Pictures .; fi
