#!/bin/bash
cd ./client/Assets/Resources/
git add .
git commit -a -m "new resource"
git push origin
cd -

cd ./Tool/
git add .
git commit -a -m "new resource"
git push origin
cd -

git add ./client/Assets/Resources/
git add ./Tool/


