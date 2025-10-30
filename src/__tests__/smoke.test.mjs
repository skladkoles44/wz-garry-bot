import { ping, getVersion } from "../index.js";
test("basic math works", () => { expect(2+2).toBe(4); });
test("ping returns pong", () => { expect(ping()).toBe("pong"); });
test("version is defined", () => { expect(getVersion()).toBe("1.0.0"); });
