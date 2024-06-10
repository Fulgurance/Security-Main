class Target < ISM::Software

    def prepare
        super

        fileReplaceText("#{buildDirectoryPath}/Makefile","$(LIBDIR)/$(PKGCONFIG_DIR)","/usr/lib/pkgconfig")
    end

    def build
        super

        makeSource(path: buildDirectoryPath)
    end

    def prepareInstallation
        super

        makeSource(["NO_ARLIB=1",
                    "LIBDIR=/usr/lib",
                    "BINDIR=/usr/bin",
                    "SBINDIR=/usr/sbin",
                    "DESTDIR=#{builtSoftwareDirectoryPath}/#{Ism.settings.rootPath}",
                    "install"],
                    path: buildDirectoryPath)
    end

end
