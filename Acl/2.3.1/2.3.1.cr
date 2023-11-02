class Target < ISM::Software

    def configure
        super
        configureSource([   "--prefix=/usr",
                            "--disable-static",
                            "--docdir=/usr/share/doc/acl-2.3.1"],
                            buildDirectoryPath)
    end

    def build
        super
        makeSource(path: buildDirectoryPath)
    end

    def prepareInstallation
        super
        makeSource(["DESTDIR=#{builtSoftwareDirectoryPath}/#{Ism.settings.rootPath}","install"],buildDirectoryPath)
    end

end
