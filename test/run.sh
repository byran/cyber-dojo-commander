#!/bin/bash

failed=0
for file in ./test_*.sh; do
  ${file}
  if [ $? != 0 ]; then
    failed=1
  fi
done

exit ${failed}