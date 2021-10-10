import * as IO from "fp-ts/IO";
import { match } from "ts-pattern";

import { Elm } from "/src/Main.elm";
import "/css/app.css";

const app = Elm.Main.init({
  node: document.getElementById("app"),
});

const openExternalLink =
  (link: string): IO.IO<void> =>
  () => {
    return window.open(link, "_blank")?.focus();
  };

app.ports.openExternalLink.subscribe((externalLink: string) => {
  return openExternalLink(externalLink)();
});
