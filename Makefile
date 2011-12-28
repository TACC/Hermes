# $Id: Makefile 317 2009-02-12 01:54:11Z mclay $

REQUIRED_PKGS	:= BeautifulTbl ColumnTable Dbg hash Optiks Optiks_Option strict \
                   fileOps string_split serializeTbl pairsByKeys
CMDS		:= findcmd testFinish testcleanup tm updateProjectDataVersion wrapperDiff
BINList		:= $(patsubst %, bin/%, $(CMDS)) bin/lua_cmd
CMDList		:= $(CMDS) lib
VERSION		:= $(shell updateProjectDataVersion --version)


MAIN_DIR := Hermes.db Makefile COPYRIGHT


dist:  
	$(MAKE) DistD=DIST _dist

_dist:  _distMkDir _distMainDir _distBin _distCmds _distCleanupSVN _distReqPkg _distTar

_distMkDir:
	$(RM) -r $(DistD)
	mkdir $(DistD)

_distMainDir:
	cp $(MAIN_DIR) $(DistD)

_distBin:
	mkdir $(DistD)/bin
	cp $(BINList) $(DistD)/bin

_distCmds:
	cp -r $(CMDList) $(DistD)


_distCleanupSVN:
	find $(DistD) -name .svn | xargs rm -rf 

_distReqPkg:
	cp `findLuaPkgs $(REQUIRED_PKGS)` $(DistD)/lib

_distTar:
	echo "hermes"-$(VERSION) > .fname;                		   \
	$(RM) -r `cat .fname` `cat .fname`.tar*;         		   \
	mv ${DistD} `cat .fname`;                            		   \
	tar chf `cat .fname`.tar `cat .fname`;           		   \
	bzip2 `cat .fname`.tar;                           		   \
	rm -rf `cat .fname` .fname; 


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
