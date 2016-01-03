.PHONY: default
default: all

SQL_startServer ?= cd ~/git/vagrant-boxes && vagrant up 2>&1 >/dev/null
SQL_sqshFlags   ?= -S localhost:1433 -U sa -P vagrant -G 7.0 -mcsv
SQL_dbDir       ?= db
include Makefiles/SQL.mk
TEST_testDir    ?= test
include Makefiles/Test.mk

vpath %.sql src

DB_NAME = cr115012

DATABASE  = $(call SQL_mkDatabaseTarget,$(DB_NAME))
QUERYSET  = $(call SQL_mkScriptSetTarget,$(DB_NAME),queryset)
QUERYTEST = $(call TEST_mkCompareTarget,$(QUERYSET))

$(DATABASE): create_$(DB_NAME).sql
$(QUERYSET): query.sql

.PHONY: all
all: db test

.PHONY: db
db: $(DATABASE)

.PHONY: test
test: $(QUERYTEST)

.PHONY: expected
expected: $(call TEST_mkGoldTarget,$(QUERYTEST))
