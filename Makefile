REQUIRED_PKGS	:= BeautifulTbl ColumnTable Dbg hash Optiks Optiks_Option strict   \
                   fileOps string_utils serializeTbl pairsByKeys TermWidth Stencil \
                   capture declare inherits
CMDS		:= findcmd testFinish testcleanup tm updateProjectDataVersion wrapperDiff
BINList		:= $(patsubst %, bin/%, $(CMDS)) bin/lua_cmd
CMDList		:= $(CMDS) lib
VERSION		:= $(shell updateProjectDataVersion --version)


MAIN_DIR := Hermes.db Makefile COPYRIGHT


dist:
	GIT_BRANCH=`git status | head -n 1 | sed -e 's/^[# ]*On branch //g' -e 's/^[# ]*HEAD detached at//g'`  ; \
	git archive --prefix=hermes-$(VERSION)/ $$GIT_BRANCH > hermes-$(VERSION).tar                           ; \
        $(RM) -rf DIST                                                                                         ; \
        mkdir DIST                                                                                             ; \
        cd DIST                                                                                                ; \
        tar xf ../hermes-$(VERSION).tar                                                                        ; \
        find hermes-$(VERSION) -type f      -print0 | xargs -0 sed -i.bk 's/\@git\@/$(GIT_VERSION)/g'          ; \
        find hermes-$(VERSION) -name '*.bk' -exec rm -f {} \;                                                  ; \
        $(RM) ../hermes-$(VERSION).tar                                                                         ; \
        tar cjf ../hermes-$(VERSION).tar.bz2 hermes-$(VERSION)                                                 ; \
	cd ..; $(RM) -rf DIST


install:  $(INSTALLDIR)
	cp -r * $(INSTALLDIR)
	$(RM) $(INSTALLDIR)/bin/updateProjectDataVersion

$(INSTALLDIR):
	mkdir -p $@

gittag:
        ifneq ($(TAG),)
	  @git status -s > /tmp/hermes$$$$;                                      \
          if [ -s /tmp/hermes$$$$ ]; then                                        \
	    echo "All files not checked in => try again";                        \
	  else                                                                   \
	    updateProjectDataVersion --new_version $(TAG);                       \
            git commit -m "moving to TAG_VERSION $(TAG)"             Hermes.db;  \
            git tag -a $(TAG) -m 'Setting TAG_VERSION to $(TAG)'              ;  \
          fi;                                                                    \
          rm -f /tmp/hermes$$$$
        else
	  @echo "To git tag do: make gittag TAG=?"
        endif

world_update:
	@git status -s > /tmp/git_st_$$$$;                                         \
        if [ -s /tmp/git_st_$$$$ ]; then                                           \
            echo "All files not checked in => try again";                          \
        else                                                                       \
	    branchName=`git status | head -n 1 | sed 's/^[# ]*On branch //g'`;	   \
            git push        github     $$branchName;                               \
            git push --tags github     $$branchName;                               \
            git push        rtm_github $$branchName;                               \
            git push --tags rtm_github $$branchName;                               \
        fi;                                                                        \
        rm -f /tmp/git_st_$$$$
