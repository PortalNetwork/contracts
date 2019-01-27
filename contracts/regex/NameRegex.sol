pragma solidity ^0.4.24;

contract NameRegex {
    struct NameState {
        bool accepts;
        function (byte) pure internal returns (NameState memory) func;
    }

    string public constant regex = "([a-z0-9-]{0,}[a-z0-9])?";

    function n0(byte c) pure internal returns (NameState memory) {
        c = c;
        return NameState(false, n0);
    }

    function n1(byte c) pure internal returns (NameState memory) {
        if (c == 45) {
            return NameState(false, n2);
        }
        if (c >= 48 && c <= 57 || c >= 97 && c <= 122) {
            return NameState(true, n3);
        }

        return NameState(false, n0);
    }

    function n2(byte c) pure internal returns (NameState memory) {
        if (c == 45) {
            return NameState(false, n2);
        }
        if (c >= 48 && c <= 57 || c >= 97 && c <= 122) {
            return NameState(true, n3);
        }

        return NameState(false, n0);
    }

    function n3(byte c) pure internal returns (NameState memory) {
        if (c == 45) {
            return NameState(false, n2);
        }
        if (c >= 48 && c <= 57 || c >= 97 && c <= 122) {
            return NameState(true, n3);
        }

        return NameState(false, n0);
    }

    function nameMatches(string input) public pure returns (bool) {
        NameState memory cur = NameState(false, n1);

        for (uint i = 0; i < bytes(input).length; i++) {
            byte c = bytes(input)[i];

            cur = cur.func(c);
        }

        return cur.accepts;
    }
}
