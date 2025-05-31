#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QQuickWidget>
#include <QQmlContext>
#include <QFileDialog>
#include "xmlreader.h"

QT_BEGIN_NAMESPACE
namespace Ui {
class MainWindow;
}
QT_END_NAMESPACE

// Главное окно приложения, отвечающее за интерфейс пользователя
class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    // Конструктор и деструктор
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    // Слот для открытия XML файла
    void openFile();

private:
    Ui::MainWindow *ui;                // Указатель на UI форму
    QQuickWidget *m_quickWidget;       // Виджет для отображения QML
    XMLReader *m_xmlReader;            // Класс для чтения XML файлов
};
#endif // MAINWINDOW_H
