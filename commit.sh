#!/bin/bash
cd ./client/Assets/Resources/
git add .
git commit -a -m "new resource"
cd -

cd ./Tool/
git add .
git commit -a -m "new resource"
cd -

git add ./client/Assets/Resources/
git add ./Tool/


