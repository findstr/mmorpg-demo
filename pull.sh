#!/bin/bash
cd ./client/Assets/Resources/
git checkout master
git pull origin
cd -

cd ./Tool/
git checkout master
git pull origin
cd -

cd ./server/silly
git checkout dev
git pull origin
cd -

