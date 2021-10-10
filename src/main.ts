import * as IO from "fp-ts/IO";
import { match } from "ts-pattern";

import { Elm } from "/src/Main.elm";
import "/css/app.css";

const app = Elm.Main.init({
  node: document.getElementById("app"),
  flags: null,
});

const openExternalLink =
  (url: string): IO.IO<void> =>
  () => {
    return window.open(url, "_blank")?.focus();
  };

app.ports.interopFromElm.subscribe((fromElm) => {
  return match(fromElm)
    .with({ tag: "openExternalLink" }, ({ url }) => openExternalLink(url)())
    .exhaustive();
});
