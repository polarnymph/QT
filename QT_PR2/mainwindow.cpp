#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QVBoxLayout>
#include <QMenuBar>
#include <QMenu>
#include <QAction>
#include <QUrl>
#include <QQmlEngine>
#include <QMessageBox>

// Конструктор главного окна
MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
    , m_xmlReader(new XMLReader(this))
{
    ui->setupUi(this);
    
    QMenu *fileMenu = menuBar()->addMenu(tr("&Файл"));
    QAction *openAction = fileMenu->addAction(tr("&Открыть XML..."));
    // Подключаем сигнал выбора действия к слоту openFile
    connect(openAction, &QAction::triggered, this, &MainWindow::openFile);
    
    // Создаем QQuickWidget для отображения QML
    m_quickWidget = new QQuickWidget(this);
    // Устанавливаем режим изменения размера (подгонка корневого объекта QML под размер виджета)
    m_quickWidget->setResizeMode(QQuickWidget::SizeRootObjectToView);
    
    // Создаем центральный виджет и компоновщик
    QWidget *centralWidget = new QWidget(this);
    QVBoxLayout *layout = new QVBoxLayout(centralWidget);
    layout->setContentsMargins(0, 0, 0, 0);
    layout->addWidget(m_quickWidget);
    
    // Устанавливаем центральный виджет
    setCentralWidget(centralWidget);
    
    // Устанавливаем контекст QML и передаем объект XMLReader
    m_quickWidget->rootContext()->setContextProperty("xmlReader", m_xmlReader);
    
    // Загружаем QML файл
    m_quickWidget->setSource(QUrl("qrc:/main.qml"));
    
    // Устанавливаем свойства окна
    setWindowTitle(tr("Просмотр диаграмм развертывания сети"));
    resize(800, 600);
}

MainWindow::~MainWindow()
{
    delete ui;
}

// Слот для открытия XML файла
void MainWindow::openFile()
{
    // Показываем диалог выбора файла
    QString filePath = QFileDialog::getOpenFileName(this, 
        tr("Открыть XML файл"), "", tr("XML файлы (*.xml)"));
    
    if (!filePath.isEmpty()) {
        if (m_xmlReader->loadFile(filePath)) {
            // Сигнал dataChanged будет отправлен автоматически из XMLReader
        } else {
            QMessageBox::warning(this, tr("Ошибка"),
                tr("Не удалось загрузить XML файл. Пожалуйста, проверьте формат файла."));
        }
    }
}
