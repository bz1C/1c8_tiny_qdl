// Библиотека "быстрой" разработки на платформе 1С:Предприятие 8
// Модуль ББР_РаботаСГипертекстовойРазметкойКлиентСервер. Версия 1.0 от 06.10.2024
// Назначение: Содержит методы для работы с гипертекстовой разметкой
// Зависимости: нет.
// Автор: Чернуль Александр Владимирович. E-mail: bzero@yandex.ru
// Лицензия на использование: Freeware (при указании автора разработки).

#Область ПрограммныйИнтерфейс

Функция ЭкранироватьТекстДляHTML(знач ТекстДляПреобразования) Экспорт
	Д = Новый ДокументHTML;
	Узел = Д.СоздатьТекстовыйУзел(ТекстДляПреобразования);
	Д.ЭлементДокумента.ДобавитьДочерний(Узел);
	
	ЗаписьDOM = Новый ЗаписьDOM;
	ЗаписьHTML = Новый ЗаписьHTML;
	ЗаписьHTML.УстановитьСтроку();
	ЗаписьDOM.Записать(Д, ЗаписьHTML);

	Возврат ЗаписьHTML.Закрыть();	
КонецФункции

#КонецОбласти
