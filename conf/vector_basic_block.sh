#!/bin/bash

__pushd ./assets/minecraft/textures/blocks/

__vector_render "$1" "${2}.svg"

__popd

exit
