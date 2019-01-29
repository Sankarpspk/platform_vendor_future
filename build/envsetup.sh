function hmm() {
cat <<EOF
Invoke ". build/envsetup.sh" from your shell to add the following functions to your environment:
- lunch:     lunch <product_name>-<build_variant>


Look at the source to view more functions. The complete list is:
EOF
    local T=$(gettop)
    local A=""
    local i
    for i in `cat $T/build/envsetup.sh | sed -n "/^[[:blank:]]*function /s/function \([a-z_]*\).*/\1/p" | sort | uniq`; do
      A="$A $i"
    done
    echo $A
}

function mk_timer()
{
    local start_time=$(date +"%s")
    $@
    local ret=$?
    local end_time=$(date +"%s")
    local tdiff=$(($end_time-$start_time))
    local hours=$(($tdiff / 3600 ))
    local mins=$((($tdiff % 3600) / 60))
    local secs=$(($tdiff % 60))
    local ncolors=$(tput colors 2>/dev/null)
    echo
    if [ $ret -eq 0 ] ; then
        echo -n "#### make completed successfully "
    else
        echo -n "#### make failed to build some targets "
    fi
    if [ $hours -gt 0 ] ; then
        printf "(%02g:%02g:%02g (hh:mm:ss))" $hours $mins $secs
    elif [ $mins -gt 0 ] ; then
        printf "(%02g:%02g (mm:ss))" $mins $secs
    elif [ $secs -gt 0 ] ; then
        printf "(%s seconds)" $secs
    fi
    echo " ####"
    echo
    return $ret
}

function repopick()
{
    T=$(gettop)
    $T/vendor/future/build/tools/repopick.py $@
}

if [ "x$SHELL" != "x/bin/bash" ]; then
    case `ps -o command -p $$` in
        *bash*)
            ;;
        *)
            echo "WARNING: Only bash is supported, use of other shell would lead to erroneous results"
            ;;
    esac
fi

# Make using all available CPUs
function mka() {
    m -j "$@"
}

function cout()
{
    if [  "$OUT" ]; then
        cd $OUT
    else
        echo "Couldn't locate out directory.  Try setting OUT."
    fi
}

function fixup_common_out_dir() {
    common_out_dir=$(get_build_var OUT_DIR)/target/common
    target_device=$(get_build_var TARGET_DEVICE)
    if [ ! -z $AOSIP_FIXUP_COMMON_OUT ]; then
        if [ -d ${common_out_dir} ] && [ ! -L ${common_out_dir} ]; then
            mv ${common_out_dir} ${common_out_dir}-${target_device}
            ln -s ${common_out_dir}-${target_device} ${common_out_dir}
        else
            [ -L ${common_out_dir} ] && rm ${common_out_dir}
            mkdir -p ${common_out_dir}-${target_device}
            ln -s ${common_out_dir}-${target_device} ${common_out_dir}
        fi
    else
        [ -L ${common_out_dir} ] && rm ${common_out_dir}
        mkdir -p ${common_out_dir}
    fi
}

# Enable SD-LLVM if available
if [ -d $(gettop)/prebuilts/snapdragon-llvm/toolchains ]; then
    case `uname -s` in
        Darwin)
            # Darwin is not supported yet
            ;;
        *)
            export SDCLANG=true
            export SDCLANG_PATH=$(gettop)/prebuilts/snapdragon-llvm/toolchains/llvm-Snapdragon_LLVM_for_Android_4.0/prebuilt/linux-x86_64/bin
            export SDCLANG_LTO_DEFS=$(gettop)/device/qcom/common/sdllvm-lto-defs.mk
            ;;
    esac
fi

# Android specific JACK args
if [ -n "$JACK_SERVER_VM_ARGUMENTS" ] && [ -z "$ANDROID_JACK_VM_ARGS" ]; then
    export ANDROID_JACK_VM_ARGS=$JACK_SERVER_VM_ARGUMENTS
fi
