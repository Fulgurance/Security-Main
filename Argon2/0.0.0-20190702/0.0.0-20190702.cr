class Target < ISM::Software

    def build
        super

        makeSource( arguments:  "PREFIX=/usr",
                    path:       buildDirectoryPath)
    end

    def prepareInstallation
        super

        makeSource( arguments:  "DESTDIR=#{builtSoftwareDirectoryPath}/#{Ism.settings.rootPath} install PREFIX=/usr",
                    path:       buildDirectoryPath)
    end

end
