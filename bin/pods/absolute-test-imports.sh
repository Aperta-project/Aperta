sed_str='s@\..*helpers/@tahi/tests/helpers/@'
fun()
{
    ag -l -0 from.*\'[.].*helpers ../../client/tests |\
        xargs -0 $SED_CMD
}
case "$1" in
    "run")
        SED_CMD="sed --in-place -e $sed_str"
        fun
    ;;
    "test")
        SED_CMD="sed -n -e ${sed_str}p"
        fun
    ;;
    *)
        echo "Usage: sh $0 {run|test}"
    ;;
esac
