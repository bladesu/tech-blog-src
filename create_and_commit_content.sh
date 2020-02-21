#!/bin/bash

hugo -D
commit_info="Update with tech-blog-src:"$(git log | head -n 1)
echo $commit_info
cd public && git add . && git commit -m "$commit_info"
cd ..
exit 0