const dns = require("dns");

async function validateEmailAddress(email) {
  const emailRegex = /^[^@]+@[^@]+\.[^@]+$/;
  if (!emailRegex.test(email)) return false;

  const domain = email.split("@")[1];
  try {
    const records = await dns.promises.resolveMx(domain);
    return records.length > 0;
  } catch {
    return false;
  }
}

module.exports = { validateEmailAddress };
