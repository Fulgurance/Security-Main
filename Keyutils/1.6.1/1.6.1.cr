class Target < ISM::Software

    def prepare
        super

        fileReplaceText(path:       "#{buildDirectoryPath}/Makefile",
                        text:       "$(LIBDIR)/$(PKGCONFIG_DIR)",
                        newText:    "/usr/lib/pkgconfig")
    end

    def build
        super

        makeSource(path: buildDirectoryPath)
    end

    def prepareInstallation
        super

        makeSource( arguments:  "NO_ARLIB=1                                                     \
                                LIBDIR=/usr/lib                                                 \
                                BINDIR=/usr/bin                                                 \
                                SBINDIR=/usr/sbin                                               \
                                DESTDIR=#{builtSoftwareDirectoryPath}/#{Ism.settings.rootPath}  \
                                install",
                    path:       buildDirectoryPath)
    end

end
