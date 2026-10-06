"use strict";

// Classic Element injects its registration bridge after loading this page.
window.matrixRegistration = {};

const form = document.getElementById("registration");
const status = document.getElementById("status");
const button = form.querySelector("button");

async function registerAccount(details, invitationToken) {
  let auth;
  for (let attempt = 0; attempt < 4; attempt++) {
    const response = await fetch("/_matrix/client/v3/register", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      credentials: "omit",
      cache: "no-store",
      body: JSON.stringify({ ...details, ...(auth ? { auth } : {}) }),
    });
    const data = await response.json();
    if (response.ok) return data;
    if (response.status !== 401 || data.error) {
      throw new Error(data.error || "Registration failed. Please try again.");
    }
    const flow = data.flows?.find(({ stages }) => stages.every((stage) =>
      ["m.login.registration_token", "m.login.dummy"].includes(stage)));
    const stage = flow?.stages.find((value) => !(data.completed || []).includes(value));
    if (!stage || !data.session) {
      throw new Error("This server requires a registration step this page cannot complete.");
    }
    auth = { type: stage, session: data.session };
    if (stage === "m.login.registration_token") auth.token = invitationToken;
  }
  throw new Error("Registration did not complete. Please try again.");
}

form.addEventListener("submit", async (event) => {
  event.preventDefault();
  const password = document.getElementById("password").value;
  if (password !== document.getElementById("confirm-password").value) {
    status.textContent = "The passwords do not match.";
    return;
  }
  button.disabled = true;
  status.textContent = "Creating your account…";
  try {
    const nativeBridge = typeof window.sendObjectMessage === "function";
    const details = {
      username: document.getElementById("username").value.trim().toLowerCase(),
      password,
      inhibit_login: !nativeBridge,
      initial_device_display_name: "Element",
    };
    const deviceId = new URLSearchParams(window.location.search).get("device_id");
    if (deviceId) details.device_id = deviceId;
    const credentials = await registerAccount(
      details, document.getElementById("registration-token").value.trim());
    form.reset();
    form.hidden = true;
    status.textContent = `Account ${credentials.user_id} created. Return to Element to sign in.`;
    if (nativeBridge) {
      credentials.home_server ||= credentials.user_id.split(":").slice(1).join(":");
      credentials.well_known ||= { "m.homeserver": { base_url: window.location.origin } };
      // Android expects credentials; iOS uses the three legacy fields.
      window.sendObjectMessage({
        action: "onRegistered",
        credentials,
        homeServer: window.location.origin,
        userId: credentials.user_id,
        accessToken: credentials.access_token,
      });
    }
  } catch (error) {
    status.textContent = error.message || "Cannot reach the server. Please try again.";
  } finally {
    button.disabled = false;
  }
});
