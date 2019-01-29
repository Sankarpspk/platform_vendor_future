include vendor/future/config/BoardConfigKernel.mk

ifeq ($(BOARD_USES_QCOM_HARDWARE),true)
include vendor/future/config/BoardConfigQcom.mk
endif

include vendor/future/config/BoardConfigSoong.mk
