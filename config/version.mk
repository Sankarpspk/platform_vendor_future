# Copyright (C) 2016-2017 Future-OS
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Versioning System
PRODUCT_VERSION_MAJOR = 9
PRODUCT_VERSION_MINOR = 0

DATE := $(shell date +%Y%m%d)
TARGET_PRODUCT_SHORT := $(subst aosip_,,$(FUTURE_BUILDTYPE))

FUTURE_BUILDTYPE ?= Pizza
FUTURE_BUILD_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)
FUTURE_VERSION := $(FUTURE_BUILD_VERSION)-$(FUTURE_BUILDTYPE)-$(FUTURE_BUILD)-$(DATE)
ROM_FINGERPRINT := Future-os/$(PLATFORM_VERSION)/$(TARGET_PRODUCT_SHORT)/$(shell date -u +%H%M)

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
  ro.future.build.version=$(FUTURE_BUILD_VERSION) \
  ro.future.build.date=$(DATE) \
  ro.future.buildtype=$(FUTURE_BUILDTYPE) \
  ro.future.fingerprint=$(ROM_FINGERPRINT) \
  ro.future.version=$(FUTURE_VERSION) \
  ro.future.device=$(FUTURE_BUILD) \
  ro.modversion=$(FUTURE_VERSION)

