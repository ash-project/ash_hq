// Announces what the MCP post's tool listing figure (templates/components/tool-listing.html) shows
// for the actor picked. The figure switches in CSS, so it works without this script.

const messages = {
  writer: "Signed in as a writer: tools/list has get_post and list_posts. publish_post isn't listed, as its policy doesn't pass.",
  editor: "Signed in as an editor: tools/list has get_post, list_posts and publish_post.",
};

for (const figure of document.querySelectorAll("[data-tool-listing]")) {
  const status = figure.querySelector("[data-tool-listing-status]");
  figure.addEventListener("change", (event) => {
    status.textContent = messages[event.target.value] ?? "";
  });
}
