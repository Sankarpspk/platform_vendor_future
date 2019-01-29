# Inherit common stuff
$(call inherit-product, vendor/future/config/common.mk)

# World APN list
PRODUCT_COPY_FILES += \
    vendor/future/prebuilt/common/etc/apns-conf.xml:system/etc/apns-conf.xml

# World SPN overrides list
PRODUCT_COPY_FILES += \
    vendor/future/prebuilt/common/etc/spn-conf.xml:system/etc/spn-conf.xml

# Selective SPN list for operator number who has the problem.
PRODUCT_COPY_FILES += \
    vendor/future/prebuilt/common/etc/selective-spn-conf.xml:system/etc/selective-spn-conf.xml

# SIM Toolkit
PRODUCT_PACKAGES += \
    Stk

# Sensitive Phone Numbers list
PRODUCT_COPY_FILES += \
    vendor/future/prebuilt/common/etc/sensitive_pn.xml:system/etc/sensitive_pn.xml
