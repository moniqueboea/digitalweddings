component output="false" {

    public struct function createToken() {
        var raw = lCase(reReplace(createUUID(), "-", "", "all")) & lCase(reReplace(createUUID(), "-", "", "all"));
        return {
            raw: raw,
            hash: hash(raw, "SHA-256")
        };
    }
}
