# $MirOS: src/bin/mksh/Makefile,v 1.37 2007/04/23 20:37:16 tg Exp $
#-
# use CPPFLAGS=-DDEBUG __CRAZY=Yes to check for certain more stuff

.include <bsd.own.mk>

PROG=		mksh
SRCS=		alloc.c edit.c eval.c exec.c expr.c funcs.c histrap.c \
		jobs.c lex.c main.c misc.c shf.c syn.c tree.c var.c
.if !make(test-build)
CPPFLAGS+=	-DMKSH_ASSUME_UTF8 \
		-DHAVE_ATTRIBUTE=1 -DHAVE_ATTRIBUTE_BOUNDED=1 \
		-DHAVE_ATTRIBUTE_USED=1 -DHAVE_SYS_PARAM_H=1 \
		-DHAVE_SYS_MKDEV_H=0 -DHAVE_SYS_MMAN_H=1 \
		-DHAVE_SYS_SYSMACROS_H=0 -DHAVE_LIBGEN_H=1 -DHAVE_PATHS_H=1 \
		-DHAVE_STDBOOL_H=1 -DHAVE_STDINT_H=1 -DHAVE_GRP_H=1 \
		-DHAVE_ULIMIT_H=0 -DHAVE_VALUES_H=0 -DHAVE_RLIM_T=1 \
		-DHAVE_SIG_T=1 -DHAVE_MKSH_SIGNAME=0 -DHAVE_SYS_SIGNAME=1 \
		-DHAVE__SYS_SIGNAME=0 -DHAVE_SYS_SIGLIST=1 -DHAVE_STRSIGNAL=0 \
		-DHAVE_ARC4RANDOM=1 -DHAVE_ARC4RANDOM_PUSH=1 -DHAVE_FLOCK_EX=1 \
		-DHAVE_SETLOCALE_CTYPE=0 -DHAVE_LANGINFO_CODESET=0 \
		-DHAVE_REVOKE=1 -DHAVE_SETMODE=1 -DHAVE_SETRESUGID=1 \
		-DHAVE_SETGROUPS=1 -DHAVE_STRCASESTR=1 -DHAVE_STRLCPY=1 \
		-DHAVE_SYS_SIGLIST_DEFN=1 -DHAVE_PERSISTENT_HISTORY=1 \
		-DHAVE_MULTI_IDSTRING=1
COPTS+=		-std=gnu99 -Wall
.endif

LINKS+=		${BINDIR}/${PROG} ${BINDIR}/sh
MLINKS+=	${PROG}.1 sh.1

regress: ${PROG} check.pl check.t
	-rm -rf regress-dir
	mkdir -p regress-dir
	echo export FNORD=666 >regress-dir/.mkshrc
	HOME=$$(readlink -nf regress-dir) perl ${.CURDIR}/check.pl \
	    -s ${.CURDIR}/check.t -v -p ./${PROG} -C pdksh

test-build: .PHONY
	-rm -rf build-dir
	mkdir -p build-dir
	cd build-dir; env CC=${CC:Q} CFLAGS=${CFLAGS:M*:Q} \
	    CPPFLAGS=${CPPFLAGS:M*:Q} LDFLAGS=${LDFLAGS:M*:Q} \
	    LIBS= NOWARN=-Wno-error TARGET_OS= CPP= /bin/sh \
	    ${.CURDIR}/Build.sh -d -r && ./test.sh -v

cleandir: clean-extra

clean-extra: .PHONY
	-rm -rf build-dir regress-dir

distribution:
	${INSTALL} ${INSTALL_COPY} -o ${BINOWN} -g ${CONFGRP} -m 0644 \
	    ${.CURDIR}/dot.mkshrc ${DESTDIR}/etc/skel/.mkshrc

.include <bsd.prog.mk>
