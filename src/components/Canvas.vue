<template>
    <div>
        <canvas
            id="mnistCanvas"
            ref="mnistCanvas"
            class="mnistCanvas"
            :width="canvasSize.width"
            :height="canvasSize.height"
            @mousedown="handleMouseDown"
            @mouseup="handleMouseUp"
            @mousemove="handleMouseMove"
            @mouseout="handleMouseOut"
        />
    </div>
</template>

<script>
const canvasSize = {
    width: 250,
    height: 250
}

export default {
    data() {
        return {
            canvasSize: canvasSize,
            mouse: {
                x: 0,
                y: 0,
                down: false,
            }
        }
    },
    computed: {
        currentMouse() {
            const c = this.$refs.mnistCanvas;
            const rect = c.getBoundingClientRect();

            return {
                x: this.mouse.x - rect.left,
                y: this.mouse.y - rect.top,
            };
        },
    },
    methods: {
        draw() {
            if (this.mouse.down) {
                const ctx = this.$refs.mnistCanvas.getContext('2d');
                ctx.lineTo(this.currentMouse.x, this.currentMouse.y);
                ctx.strokeStyle = '#fff'; // 白文字
                ctx.lineWidth = 20;
                ctx.stroke();
            }
        },
        handleMouseDown(event) {
            this.mouse = {
                x: event.pageX,
                y: event.pageY,
                down: true,
            };
            const ctx = this.$refs.mnistCanvas.getContext('2d');
            ctx.moveTo(this.currentMouse.x, this.currentMouse.y);
        },
        handleMouseUp() {
            this.mouse.down = false;
        },
        handleMouseMove(event) {
            Object.assign(this.mouse, {
                x: event.pageX,
                y: event.pageY,
            });
            this.draw();
        },
        handleMouseOut() {
            this.mouse.down = false;
        },
        clear() {
            const ctx = document.getElementById('mnistCanvas').getContext('2d');
            ctx.clearRect(0, 0, canvasSize.width, canvasSize.height);
            ctx.beginPath();
        }
    }
}
</script>
<style>
.mnistCanvas {
    background-color: #000; /*黒背景*/
    width: 250px;
    height: 250px;
}
</style>
