function createEmailTemplate(title, message, code) {
  return `
  <div style="font-family: Arial, sans-serif; color: #333; background: #f9f9f9; padding: 20px; border-radius: 10px;">
    <h2 style="color:#2E9265;">${title}</h2>
    <p>${message}</p>
    ${
      code
        ? `<div style="text-align:center; margin:20px 0;">
             <h1 style="letter-spacing:4px; color:#1E7A42;">${code}</h1>
           </div>`
        : ""
    }
    <p>This code will expire in <b>5 minutes</b>.</p>
    <hr/>
    <p style="font-size:13px; color:#888;">This is an automated message from <b>SkeletonFit App</b>.</p>
  </div>
  `;
}

module.exports = { createEmailTemplate };
