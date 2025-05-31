#ifndef XMLREADER_H
#define XMLREADER_H

#include <QObject>
#include <QDomDocument>
#include <QFile>
#include <QStringList>
#include <QMap>
#include <QVariant>

// Структура для хранения информации об узле сети
struct Node {
    QString name;           // Имя узла
    QString type;           // Тип узла (сервер, устройство и т.д.)
    QStringList components; // Список компонентов внутри узла
};

// Структура для хранения информации о соединении между узлами
struct Connection {
    QString from;   // Имя исходного узла
    QString to;     // Имя целевого узла
};

// Структура для хранения информации о диаграмме развертывания
struct DeploymentDiagram {
    QString name;               // Имя диаграммы
    QList<Node> nodes;          // Список узлов диаграммы
    QList<Connection> connections; // Список соединений между узлами
};

// Класс для чтения и анализа XML файлов с диаграммами развертывания
class XMLReader : public QObject
{
    Q_OBJECT

public:
    // Конструктор
    explicit XMLReader(QObject *parent = nullptr);
    
    // Методы, доступные из QML
    Q_INVOKABLE bool loadFile(const QString &filePath);     // Загрузка XML файла
    Q_INVOKABLE DeploymentDiagram getDiagram() const;       // Получение всей диаграммы
    
    // Методы для доступа к данным из QML
    Q_INVOKABLE int getNodeCount() const;                   // Количество узлов
    Q_INVOKABLE QVariantMap getNodeAt(int index) const;     // Получение узла по индексу
    Q_INVOKABLE int getConnectionCount() const;             // Количество соединений
    Q_INVOKABLE QVariantMap getConnectionAt(int index) const; // Получение соединения по индексу
    Q_INVOKABLE QString getDiagramName() const;             // Получение имени диаграммы

signals:
    // Сигнал, сообщающий об изменении данных
    void dataChanged();

private:
    DeploymentDiagram m_diagram;              // Текущая диаграмма
    bool parseXML(const QByteArray &xmlData); // Метод для разбора XML данных
};

#endif // XMLREADER_H 