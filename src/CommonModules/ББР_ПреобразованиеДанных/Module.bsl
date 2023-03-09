// Библиотека "быстрой" разработки на платформе 1С:Предприятие 8
// Модуль ББР_СериализацияДесериализация. Версия 1.1 от 20.04.2021
// Старое название: ББР_СериализацияДесериализация. Версия 1.0 от 24.10.2018
// Назначение: Содержит функции для преобразования данных в памяти сложных типов из одного типа в другой.
// Автор: Чернуль Александр Владимирович. E-mail: bzero@yandex.ru
// Лицензия на использование: Freeware.

#Область В_таблицу_значений

Функция ПрочитатьТЗИзТабличногоДокумента(ТабДокумент, ИмяОбластиКолонок, ИмяОбластиЗаголовка, ИмяОбластиДанных, ОписаниеТипаКолонок = Неопределено) Экспорт
	ОблЗаголовок = ТабДокумент.Область(ИмяОбластиЗаголовка+"|"+ИмяОбластиКолонок);
	ТЗ = Новый ТаблицаЗначений;
	МаксИндексКолонки = -1;
	Для НомерКолонки = ОблЗаголовок.Лево По ОблЗаголовок.Право Цикл
		ИмяКолонки = ТабДокумент.Область(ОблЗаголовок.Верх, НомерКолонки, ОблЗаголовок.Верх, НомерКолонки).Текст;
		ТЗ.Колонки.Добавить(ИмяКолонки, ОписаниеТипаКолонок);
		МаксИндексКолонки = МаксИндексКолонки + 1;
	КонецЦикла;
	
	ОблДанные = ТабДокумент.Область(ИмяОбластиДанных+"|"+ИмяОбластиКолонок);
	Для НомерСтроки = ОблДанные.Верх По ОблДанные.Низ Цикл
		НовСтр = ТЗ.Добавить();
		Для ИндексКолонки = 0 По МаксИндексКолонки Цикл
			НомерКолонки = ИндексКолонки+ОблЗаголовок.Лево;
			НовСтр[ИндексКолонки] = ТабДокумент.Область(НомерСтроки, НомерКолонки, НомерСтроки, НомерКолонки).Текст;
		КонецЦикла; 
	КонецЦикла;
	
	Возврат ТЗ; 
КонецФункции

	
#КонецОбласти  