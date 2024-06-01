class Target < ISM::Software

    def build
        super

        makeSource(path: buildDirectoryPath)
    end

    def prepareInstallation
        super

        makeSource( ["DESTDIR=#{builtSoftwareDirectoryPath}/#{Ism.settings.rootPath}",
                    "install","PREFIX=/usr"],
                    path: buildDirectoryPath)
    end

end
