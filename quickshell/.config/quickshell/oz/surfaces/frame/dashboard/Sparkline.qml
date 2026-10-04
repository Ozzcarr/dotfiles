// Values are percentages, oldest first.
import QtQuick
import qs.config

Canvas {
    id: root

    required property int capacity
    property var values: []
    property color color: Appearance.accent

    onValuesChanged: requestPaint()
    onColorChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d");
        ctx.reset();

        if (values.length < 2)
            return;

        const step = width / (capacity - 1);
        const offset = (capacity - values.length) * step;
        const y = v => height - (Math.max(0, Math.min(100, v)) / 100) * (height - 2) - 1;

        ctx.beginPath();
        ctx.moveTo(offset, y(values[0]));
        for (let i = 1; i < values.length; i++)
            ctx.lineTo(offset + i * step, y(values[i]));

        ctx.lineWidth = 1.5;
        ctx.strokeStyle = root.color;
        ctx.stroke();

        ctx.lineTo(offset + (values.length - 1) * step, height);
        ctx.lineTo(offset, height);
        ctx.closePath();
        ctx.fillStyle = Qt.alpha(root.color, 0.18);
        ctx.fill();
    }
}
