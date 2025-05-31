import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Главный контейнер для отображения сетевой диаграммы
Rectangle {
    id: root
    color: "#f0f0f0"  // Светло-серый фон для диаграммы
    
    // Основные свойства и параметры диаграммы
    property int nodeSize: 120            // Размер узла (ширина и высота)
    property int spacing: 50              // Расстояние между узлами
    property int canvasMargin: 50         // Отступы от краёв контейнера
    property var nodePositions: ({})      // Объект для хранения позиций узлов
    property var nodeItems: []            // Массив для хранения созданных узлов
    property var connections: []          // Массив для хранения соединений между узлами
    
    // Заголовок диаграммы (имя диаграммы из XML)
    Text {
        id: diagramTitle
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            margins: 10
        }
        font.pixelSize: 20
        font.bold: true
        text: xmlReader.getDiagramName()
        visible: text.length > 0  // Показывать только если имя задано
    }
    
    // Основная область для отрисовки диаграммы
    Item {
        id: canvas
        anchors {
            fill: parent
            topMargin: diagramTitle.visible ? diagramTitle.height + 20 : 10
            margins: canvasMargin
        }
        
        // Canvas для отрисовки всех соединений между узлами
        Canvas {
            id: connectionsCanvas
            anchors.fill: parent
            z: 100  // Устанавливаем высокий z-индекс, чтобы соединения отображались поверх узлов
            
            property real arrowSize: 15  // Размер стрелки на конце соединения
            
            // Функция отрисовки всех соединений
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);  // Очищаем холст
                ctx.lineWidth = 2;                   // Толщина линии
                ctx.strokeStyle = "#555";            // Цвет линии (серый)
                ctx.fillStyle = "#555";              // Цвет заливки стрелки
                
                // Отрисовка всех соединений из массива
                for (var i = 0; i < connections.length; i++) {
                    var conn = connections[i];
                    
                    // Вычисляем угол направления соединения для правильной отрисовки стрелки
                    var angle = Math.atan2(conn.y2 - conn.y1, conn.x2 - conn.x1);
                    
                    // Рисуем линию соединения
                    ctx.beginPath();
                    ctx.moveTo(conn.x1, conn.y1);
                    // Немного укорачиваем линию, чтобы избежать наложения со стрелкой
                    var shortenedX2 = conn.x2 - 2 * Math.cos(angle);
                    var shortenedY2 = conn.y2 - 2 * Math.sin(angle);
                    ctx.lineTo(shortenedX2, shortenedY2);
                    ctx.stroke();
                    
                    // Рисуем стрелку на конце соединения
                    ctx.beginPath();
                    ctx.moveTo(conn.x2, conn.y2);  // Вершина стрелки
                    // Левая сторона стрелки
                    ctx.lineTo(
                        conn.x2 - arrowSize * Math.cos(angle - Math.PI/6),
                        conn.y2 - arrowSize * Math.sin(angle - Math.PI/6)
                    );
                    // Правая сторона стрелки
                    ctx.lineTo(
                        conn.x2 - arrowSize * Math.cos(angle + Math.PI/6),
                        conn.y2 - arrowSize * Math.sin(angle + Math.PI/6)
                    );
                    ctx.closePath();  // Замыкаем контур
                    ctx.fill();       // Заливаем треугольник
                }
            }
        }
        
        // Обработчик перемещения узла
        function handleNodeMoved(nodeName, nodeX, nodeY) {
            // Обновляем позицию узла в хранилище позиций
            if (nodePositions[nodeName]) {
                nodePositions[nodeName].x = nodeX;
                nodePositions[nodeName].y = nodeY;
                
                // Обновляем все соединения
                updateConnections();
            }
        }
        
        // Обновление всех соединений после перемещения узлов
        function updateConnections() {
            // Очищаем текущие соединения
            connections = [];
            
            // Проходим по всем соединениям из XML и обновляем их
            for (var i = 0; i < xmlReader.getConnectionCount(); i++) {
                var conn = xmlReader.getConnectionAt(i);
                if (conn.from in nodePositions && conn.to in nodePositions) {
                    createConnection(conn.from, conn.to);
                }
            }
            
            // Запрашиваем перерисовку Canvas
            connectionsCanvas.requestPaint();
        }
        
        // Функция для расчета позиций узлов и создания соединений
        function layoutNodes() {
            // Очищаем все существующие узлы
            for (var i = 0; i < nodeItems.length; i++) {
                nodeItems[i].destroy();
            }
            
            // Сбрасываем все данные
            nodeItems = [];
            nodePositions = {};
            connections = [];
            
            // Получаем количество узлов из XML
            var nodeCount = xmlReader.getNodeCount();
            if (nodeCount === 0) return;  // Если узлов нет, выходим
            
            // Рассчитываем количество строк и столбцов для сетки узлов
            var cols = Math.ceil(Math.sqrt(nodeCount));
            var rows = Math.ceil(nodeCount / cols);
            
            // Рассчитываем ширину и высоту ячейки сетки
            var colWidth = (width - spacing) / cols;
            var rowHeight = (height - spacing) / rows;
            
            // Размещаем узлы в сетке
            for (i = 0; i < nodeCount; i++) {
                var node = xmlReader.getNodeAt(i);  // Получаем данные узла из XML
                var row = Math.floor(i / cols);     // Определяем строку
                var col = i % cols;                 // Определяем столбец
                
                // Вычисляем координаты узла
                var nodeX = col * colWidth + spacing / 2;
                var nodeY = row * rowHeight + spacing / 2;
                
                // Создаем компонент узла
                var nodeComponent = Qt.createComponent("NodeItem.qml");
                if (nodeComponent.status === Component.Ready) {
                    // Создаем экземпляр узла и настраиваем его свойства
                    var nodeObject = nodeComponent.createObject(canvas, {
                        x: nodeX,
                        y: nodeY,
                        width: nodeSize,
                        height: nodeSize,
                        nodeName: node.name,         // Имя узла
                        nodeType: node.type,         // Тип узла
                        components: node.components, // Компоненты узла
                        z: 1                         // Z-индекс для правильного отображения
                    });
                    
                    // Подключаем сигнал перемещения узла
                    nodeObject.nodeMoved.connect(handleNodeMoved);
                    
                    // Добавляем узел в массив и сохраняем его позицию
                    nodeItems.push(nodeObject);
                    nodePositions[node.name] = { 
                        x: nodeX, 
                        y: nodeY, 
                        width: nodeSize, 
                        height: nodeSize 
                    };
                }
            }
            
            // Создаем соединения между узлами
            for (i = 0; i < xmlReader.getConnectionCount(); i++) {
                var conn = xmlReader.getConnectionAt(i);  // Получаем данные соединения из XML
                if (conn.from in nodePositions && conn.to in nodePositions) {
                    // Создаем соединение между узлами
                    createConnection(conn.from, conn.to);
                }
            }
            
            // Запрашиваем перерисовку холста с соединениями
            connectionsCanvas.requestPaint();
        }
        
        // Функция для нахождения точки пересечения линии с прямоугольником (узлом)
        function findIntersectionWithRectangle(sourceX, sourceY, targetX, targetY, rect) {
            // Вектор направления линии
            var dx = targetX - sourceX;
            var dy = targetY - sourceY;
            
            // Координаты сторон прямоугольника
            var left = rect.x;
            var right = rect.x + rect.width;
            var top = rect.y;
            var bottom = rect.y + rect.height;
            
            // Массив для хранения возможных точек пересечения
            var tValues = [];
            
            // Проверяем пересечение с левой стороной (x = left)
            if (dx !== 0) {
                var t1 = (left - sourceX) / dx;
                var y1 = sourceY + t1 * dy;
                if (y1 >= top && y1 <= bottom) {
                    tValues.push({t: t1, x: left, y: y1});
                }
            }
            
            // Проверяем пересечение с правой стороной (x = right)
            if (dx !== 0) {
                var t2 = (right - sourceX) / dx;
                var y2 = sourceY + t2 * dy;
                if (y2 >= top && y2 <= bottom) {
                    tValues.push({t: t2, x: right, y: y2});
                }
            }
            
            // Проверяем пересечение с верхней стороной (y = top)
            if (dy !== 0) {
                var t3 = (top - sourceY) / dy;
                var x3 = sourceX + t3 * dx;
                if (x3 >= left && x3 <= right) {
                    tValues.push({t: t3, x: x3, y: top});
                }
            }
            
            // Проверяем пересечение с нижней стороной (y = bottom)
            if (dy !== 0) {
                var t4 = (bottom - sourceY) / dy;
                var x4 = sourceX + t4 * dx;
                if (x4 >= left && x4 <= right) {
                    tValues.push({t: t4, x: x4, y: bottom});
                }
            }
            
            // Находим ближайшую точку пересечения для целевой точки
            var closestPoint = null;
            var minT = Number.MAX_VALUE;
            
            for (var i = 0; i < tValues.length; i++) {
                var point = tValues[i];
                if (point.t >= 0 && point.t < minT) {
                    minT = point.t;
                    closestPoint = point;
                }
            }
            
            return closestPoint;
        }
        
        // Функция для создания соединения между двумя узлами
        function createConnection(fromNodeName, toNodeName) {
            var fromNode = nodePositions[fromNodeName];  // Исходный узел
            var toNode = nodePositions[toNodeName];      // Целевой узел
            
            // Вычисляем центры узлов
            var fromCenterX = fromNode.x + fromNode.width/2;
            var fromCenterY = fromNode.y + fromNode.height/2;
            var toCenterX = toNode.x + toNode.width/2;
            var toCenterY = toNode.y + toNode.height/2;
            
            // Находим точки пересечения линии с границами узлов
            var fromIntersect = findIntersectionWithRectangle(toCenterX, toCenterY, fromCenterX, fromCenterY, fromNode);
            var toIntersect = findIntersectionWithRectangle(fromCenterX, fromCenterY, toCenterX, toCenterY, toNode);
            
            if (fromIntersect && toIntersect) {
                // Добавляем соединение в массив соединений
                connections.push({
                    x1: fromIntersect.x,  // Начальная точка X (на границе исходного узла)
                    y1: fromIntersect.y,  // Начальная точка Y
                    x2: toIntersect.x,    // Конечная точка X (на границе целевого узла)
                    y2: toIntersect.y     // Конечная точка Y
                });
            }
        }
        
        // Выполняем построение диаграммы при инициализации компонента
        Component.onCompleted: layoutNodes()
        
        // Слушаем сигнал изменения данных от XMLReader
        Connections {
            target: xmlReader
            function onDataChanged() {
                // Перестраиваем диаграмму при изменении данных
                canvas.layoutNodes();
            }
        }
    }
} 
