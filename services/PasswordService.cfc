component output="false" {

    public struct function createHash(required string password) {
        var salt = lCase(reReplace(createUUID(), "-", "", "all"));
        var iterations = application.config.passwordHashIterations;
        var passwordHash = hash(
            arguments.password & salt,
            "SHA-512",
            "UTF-8",
            iterations
        );
        return {
            hash: passwordHash,
            salt: salt,
            iterations: iterations,
            algorithm: "SHA-512"
        };
    }

    public boolean function verify(
        required string password,
        required string expectedHash,
        required string salt,
        required numeric iterations
    ) {
        var candidate = hash(
            arguments.password & arguments.salt,
            "SHA-512",
            "UTF-8",
            arguments.iterations
        );
        return compareNoCase(candidate, arguments.expectedHash) == 0;
    }
}
