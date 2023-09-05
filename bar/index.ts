import { stuff } from "@rule-ts-transitive-dep-issues-example/foo-package";

export const new_stuff = {
    ...stuff,
    "field3": "More Hellos"
}