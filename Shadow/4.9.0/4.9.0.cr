class Target < ISM::Software

    def prepare
        super
        fileReplaceText("#{buildDirectoryPath(false)}/src/Makefile.in","groups$(EXEEXT) ","")
        replaceTextAllFilesRecursivelyNamed("#{buildDirectoryPath(false)}/man","Makefile.in","groups.1 "," ")
        replaceTextAllFilesRecursivelyNamed("#{buildDirectoryPath(false)}/man","Makefile.in","getspnam.3 "," ")
        replaceTextAllFilesRecursivelyNamed("#{buildDirectoryPath(false)}/man","Makefile.in","passwd.5 "," ")
        fileReplaceTextAtLineNumber("#{buildDirectoryPath(false)}/libmisc/salt.c","rounds","min_rounds",224)
        makeDirectory("#{builtSoftwareDirectoryPath(false)}/#{Ism.settings.rootPath}/usr/bin/")
        generateEmptyFile("#{builtSoftwareDirectoryPath(false)}/#{Ism.settings.rootPath}/usr/bin/passwd")
        generateEmptyFile("#{Ism.settings.rootPath}/usr/bin/passwd")
    end

    def configure
        super
        configureSource([   "--sysconfdir=/etc",
                            "--with-group-name-max-length=32"],
                            buildDirectoryPath)
    end

    def build
        super
        makeSource([Ism.settings.makeOptions],buildDirectoryPath)
    end

    def prepareInstallation
        super
        makeSource([Ism.settings.makeOptions,"exec_prefix=/usr","DESTDIR=#{builtSoftwareDirectoryPath}/#{Ism.settings.rootPath}","install"],buildDirectoryPath)
        makeSource([Ism.settings.makeOptions,"-C","man","DESTDIR=#{builtSoftwareDirectoryPath}/#{Ism.settings.rootPath}","install-man"],buildDirectoryPath)
        makeDirectory("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}/etc/default")
    end

    def install
        super
        runPwconvCommand
        runGrpconvCommand
    end

end
