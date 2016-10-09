#!/bin/bash

# can't remove start-point volumes in use
./../cyber-dojo down >/dev/null 2>/dev/null
# remove default start-points for clean environment on start
currentStartPoints=`./../cyber-dojo start-point ls --quiet`
defaultStartPoints=( "languages" "exercises" "custom" )
for defaultStartPoint in "${defaultStartPoints[@]}"
do
  if grep -q ${defaultStartPoint} <<< ${currentStartPoints}; then
    ./../cyber-dojo start-point rm ${defaultStartPoint}
  fi
done

# - - - - - - - - - - - - - - - - - - -

failed=0
for file in ./test_*.sh; do
  ${file}
  if [ $? != 0 ]; then
    failed=1
  fi
done

exit ${failed}
