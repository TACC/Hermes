# $Id: Makefile 317 2009-02-12 01:54:11Z mclay $

REQUIRED_PKGS	:= BeautifulTbl ColumnTable Dbg hash Optiks Optiks_Option strict \
                   fileOps string_split serialize pairsByKeys
CMDS		:= findcmd testFinish testcleanup tm updateProjectDataVersion wrapperDiff
BINList		:= $(patsubst %, bin/%, $(CMDS)) bin/lua_cmd
CMDList		:= $(CMDS) lib
VERSION		:= $(shell updateProjectDataVersion --version)


MAIN_DIR := Hermes.db Makefile


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
	gzip `cat .fname`.tar;                           		   \
	rm -rf `cat .fname` .fname; 


install:  $(INSTALLDIR)
	cp -r * $(INSTALLDIR)
	$(RM) $(INSTALLDIR)/bin/updateProjectDataVersion

$(INSTALLDIR):
	mkdir -p $@

svntag:
        ifneq ($(TAG),)
	  updateProjectDataVersion --new_version $(TAG);                             \
          SVN=`svn info | grep "Repository Root" | sed -e 's/Repository Root: //'`;  \
	  svn ci -m'moving to TAG_VERSION $(TAG)' Hermes.db;          	             \
	  svn cp -m'moving to TAG_VERSION $(TAG)' $$SVN/trunk $$SVN/tags/$(TAG)
        else
	  @echo "To svn tag do: make svntag TAG=?"
        endif
