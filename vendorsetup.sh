for f in $(cat vendor/future/future.devices); do
    add_lunch_combo foture_$f-userdebug;
done
