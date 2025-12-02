let currentUrl = null;

window.addEventListener('message', (event) => {
    const data = event.data;

    if (!data || typeof data !== 'object') return;

    if (data.type === 'show') {
        document.body.style.display = 'flex';

        currentUrl = data.url;
        const qrContainer = document.getElementById('qrcode');
        qrContainer.innerHTML = '';

        new QRCode(qrContainer, {
            text: currentUrl,
            width: 200,
            height: 200
        });
    }

    if (data.type === 'hide') {
        document.body.style.display = 'none';
    }
});

document.getElementById('closeBtn').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({})
    });
});
