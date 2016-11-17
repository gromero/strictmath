#!/bin/bash

# Usage:
# ./Math_vs_StrictMath.sh ~/hg/jdk9/hs/build/linux-ppc64le-normal-server-release/jdk/bin/

if [ ! -z $1 ]
then
  JAVA_BINARIES=$1

  if [ ! -f ${JAVA_BINARIES}/java ]
  then
    echo "No Java runtime executable found! Exiting..."
    exit 1
  fi

  if [ ! -f ${JAVA_BINARIES}/javac ]
  then
    echo "No Java compiler found! Exiting..."
    exit 1
  fi

  # Use specified java/javac.
  JAVA=${JAVA_BINARIES}/java
  JAVAC=${JAVA_BINARIES}/javac

else
# Use java/javac from environment.
JAVA=java
JAVAC=javac

fi


####################
# One arg functions.
for FUNCTION in sin cos tan asin acos atan exp log log10 sqrt cbrt sinh cosh tanh expm1 log1p
do
  MClassname=Math_${FUNCTION}
  SMClassname=StrictMath_${FUNCTION}
  outputFile=`uname -m`.txt

  # echo -n -> ${FUNCTION}
  sed "s|FUNC|${FUNCTION}|" Math_FUNC.java       > ${MClassname}.java
  sed "s|FUNC|${FUNCTION}|" StrictMath_FUNC.java > ${SMClassname}.java

  ${JAVAC} ${MClassname}.java  # Compile Math method
  ${JAVAC} ${SMClassname}.java # Compile StrictMath method

# MATH_REALTIME=$({ time ${JAVA} ${MClassname} ; } |& fgrep real | cut -f2)
# STRICT_MATH_REALTIME=$({ time ${JAVA} ${SMClassname} ; } |& fgrep real | cut -f2)
# STAT_OUTPUT="${FUNCTION} ${MATH_REALTIME} ${STRICT_MATH_REALTIME}"
#  value = egrep  "^[-]*[0-9]+" <tmpfile> 
#  et    = awk '/real/ {printf $2}' <tmpfile> 

  # Save time results and .class results in a single file.
  (time ${JAVA} ${MClassname})  &>  Math_tmp.output
  (time ${JAVA} ${SMClassname}) &> SMath_tmp.output

  MATH_RESULT=`head -1                    Math_tmp.output`
  MATH_REALTIME=`awk '/real/ {printf $2}' Math_tmp.output`

  SMATH_RESULT=`head -1                    SMath_tmp.output`
  SMATH_REALTIME=`awk '/real/ {printf $2}' SMath_tmp.output`

  STAT_OUTPUT="${FUNCTION} ${MATH_RESULT} ${MATH_REALTIME} ${SMATH_RESULT} ${SMATH_REALTIME}"
  echo ${STAT_OUTPUT}

  # x86_64.txt or ppc64le.txt
  echo ${STAT_OUTPUT} >> ${outputFile}
done

#####################
# Two args functions.
for FUNCTION in IEEEremainder atan2 pow hypot
do
  MClassname=Math_${FUNCTION}
  SMClassname=StrictMath_${FUNCTION}
  outputFile=`uname -m`.txt

  # echo T: ${FUNCTION} ->
  sed "s|FUNC|${FUNCTION}|" Math_FUNC_2args.java       > ${MClassname}.java
  sed "s|FUNC|${FUNCTION}|" StrictMath_FUNC_2args.java > ${SMClassname}.java

  ${JAVAC} ${MClassname}.java  # Compile Math method
  ${JAVAC} ${SMClassname}.java # Compile StrictMath method

  # Save time results and .class results in a single file.
  (time ${JAVA} ${MClassname})  &>  Math_tmp.output
  (time ${JAVA} ${SMClassname}) &> SMath_tmp.output

  MATH_RESULT=`head -1                    Math_tmp.output`
  MATH_REALTIME=`awk '/real/ {printf $2}' Math_tmp.output`
  
  SMATH_RESULT=`head -1                    SMath_tmp.output`
  SMATH_REALTIME=`awk '/real/ {printf $2}' SMath_tmp.output`

  STAT_OUTPUT="${FUNCTION} ${MATH_RESULT} ${MATH_REALTIME} ${SMATH_RESULT} ${SMATH_REALTIME}"
  echo ${STAT_OUTPUT}

  # x86_64.txt or ppc64le.txt
  echo ${STAT_OUTPUT} >> ${outputFile}
done
