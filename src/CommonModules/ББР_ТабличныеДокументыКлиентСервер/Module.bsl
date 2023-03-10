// Библиотека "быстрой" разработки на платформе 1С:Предприятие 8
// Модуль ББР_РаботаСТипами. Версия 1.2 от 27.03.2019
// Назначение: Содержит функции для работы с табличными документами
// Зависимости: ББР_КоллекцииКлиентСервер
// Автор: Чернуль Александр Владимирович. E-mail: bzero@yandex.ru
// Лицензия на использование: Freeware.

Процедура УстановитьШиринуОбластиНаОсновеОбластиШаблонаПоКоординатам(
				ДокументРезультат, 
				ОбластьШаблонСтрока, ОбластьШаблонЛево, ОбластьШаблонПраво,
				ОбластьУстановкиСтрока, ОбластьУстановкиЛево, ОбластьУстановкиПраво) Экспорт 
				
	
	//ШиринаТаблицы = ПосчитатьШиринуЯчеек(ДокументРезультат, ОбластьШаблонСтрока, ОбластьШаблонЛево, ОбластьШаблонПраво);
	//	
	//ШиринаЗаголовка = ПосчитатьШиринуЯчеек(ДокументРезультат, ОбластьУстановкиСтрока, ОбластьУстановкиЛево, ОбластьУстановкиПраво);
	//	
	//СтараяШиринаКолонки = ПосчитатьШиринуЯчеек(ДокументРезультат, ОбластьУстановкиСтрока, ОбластьУстановкиЛево, ОбластьУстановкиЛево);
	//
	//НоваяШиринаКолонки = СтараяШиринаКолонки + ШиринаТаблицы - ШиринаЗаголовка;
	//
	//Если НоваяШиринаКолонки > 0 Тогда
	//	УстановитьШиринуКолонки(ДокументРезультат, ОбластьУстановкиСтрока, ОбластьУстановкиЛево, НоваяШиринаКолонки);
	//КонецЕсли; 
	

//Процедура ДобавитьОтчет(ТДПриемник, Отчет)

//    НачалоНовогоФорматаСтрок = ТДПриемник.ВысотаТаблицы + 1;
//    ОбластьПрямоугольная = Отчет.Область(1, , Отчет.ВысотаТаблицы, );
//    ТДПриемник.ВставитьОбласть(ОбластьПрямоугольная, ТДПриемник.Область(НачалоНовогоФорматаСтрок, 1));
//    ТДПриемник.Область(НачалоНовогоФорматаСтрок, , 
//        НачалоНовогоФорматаСтрок + Отчет.ВысотаТаблицы - 1, ).СоздатьФорматСтрок();
//    // назначим ширину колонок у новой области формата строк

//    Для Счетчик = 1 По Отчет.ШиринаТаблицы Цикл
//        ТДПриемник.Область(НачалоНовогоФорматаСтрок, Счетчик).ШиринаКолонки = Отчет.Область(1, Счетчик).ШиринаКолонки;
//    КонецЦикла;
//    ТДПриемник.ВывестиГоризонтальныйРазделительСтраниц();

//КонецПроцедуры // ДобавитьОтчет

 
	
	
				
КонецПроцедуры
 

Процедура УстановитьШиринуКолонки(ДокументРезультат, Стр, Кол, НоваяШиринаКолонки) Экспорт 
	ДокументРезультат.ВыделенныеОбласти.Очистить(); 
	ДокументРезультат.ВыделенныеОбласти.Добавить(ДокументРезультат.Область(стр,,стр));
	ДокументРезультат.Область(,кол,,кол).ШиринаКолонки = НоваяШиринаКолонки;
КонецПроцедуры
 
Функция ПосчитатьШиринуЯчеек(ТабДок, Верх, Лево, Право) Экспорт
	ТекКолонка = Лево;
	ШиринаЯчеек = 0;
	
	ТабДок.ВыделенныеОбласти.Очистить(); 
	ТабДок.ВыделенныеОбласти.Добавить(ТабДок.Область(Верх,,Верх));
	
	Для сч=Лево По Право Цикл
		ТекОбласть = ТабДок.Область(,сч,, сч);
		ШиринаЯчеек = ШиринаЯчеек + ТекОбласть.ШиринаКолонки;
	КонецЦикла; 

	Возврат ШиринаЯчеек; 	
КонецФункции
 

Функция НайтиПодрядИдущиеОбластиВСтрокеСОдинаковымТекстом(ДокументРезультат, ИскомыйТекст, ПолноеСовпадение = Истина, Начало = Неопределено, Где = Неопределено, ИскатьПоГоризонтали = Истина) Экспорт
	
	Перем ТекущаяОбласть;
	
	НайденаПерваяОбласть = ДокументРезультат.НайтиТекст(
		ИскомыйТекст,
		Начало,
		Где,
		Истина,
		ПолноеСовпадение,
		Истина,
		Истина
	);
	
	Если НайденаПерваяОбласть <> Неопределено Тогда
		ТекущаяОбласть = НайденаПерваяОбласть;
		НайденаПоследняяОбласть = Неопределено;
		Пока ТекущаяОбласть.Текст = НайденаПерваяОбласть.Текст Цикл
			НайденаПоследняяОбласть = ТекущаяОбласть;
			Если ИскатьПоГоризонтали = Истина Тогда
				ТекущаяОбласть = ДокументРезультат.Область(НайденаПоследняяОбласть.Верх, НайденаПоследняяОбласть.Право+1);
			Иначе
				ТекущаяОбласть = ДокументРезультат.Область(НайденаПоследняяОбласть.Низ+1, НайденаПоследняяОбласть.Лево);
			КонецЕсли; 
		КонецЦикла;
		
		Если НайденаПоследняяОбласть = Неопределено Тогда
			Возврат Неопределено; 
		Иначе
			Возврат Новый Структура(
				"ОбластьНачало, ОбластьКонец, ОбластьДляОбъединения", 
				НайденаПерваяОбласть, 
				НайденаПоследняяОбласть,
				ДокументРезультат.Область(
					НайденаПерваяОбласть.Верх, НайденаПерваяОбласть.Лево,
					НайденаПоследняяОбласть.Низ, НайденаПоследняяОбласть.Право
				)
			); 
		КонецЕсли; 
	Иначе
		Возврат Неопределено; 
	КонецЕсли;

КонецФункции


//Процедура ОбъединитьОдинаковыеЯчейкиПоГоризонтали(ТабДокумент, ОбластьНачало, ОбластьКонец) Экспорт 
//	НачалоТекущейОбласти = ОбластьНачало;
//	ТекущаяОбласть = ОбластьНачало;
//	ТекущийТекст = ОбластьНачало.Текст;
//	Пока ТекущаяОбласть.Лево <= ОбластьКонец.Право Цикл
//		Если ТекущийТекст <> ТекущаяОбласть.Текст Тогда
//			Если НачалоТекущейОбласти.Право+1 <> ТекущаяОбласть.Лево Тогда
//				Область = ТабДокумент.Область(
//					НачалоТекущейОбласти.Верх, НачалоТекущейОбласти.Лево,
//					ТекущаяОбласть.Низ, ТекущаяОбласть.Лево-1
//				);

//				Область.Разъединить();
//				Область.Объединить();
//			КонецЕсли; 
//			
//			ТекущийТекст = ТекущаяОбласть.Текст;
//			НачалоТекущейОбласти = ТекущаяОбласть;
//		КонецЕсли; 
//		ТекущаяОбласть = ТабДокумент.Область(ТекущаяОбласть.Верх, ТекущаяОбласть.Право+1);
//	КонецЦикла;
//КонецПроцедуры

// Зависит от: ББР_КоллекцииКлиентСервер
Функция ОбъединитьОдинаковыеЗаголовкиСОднимШаблоном(ТабДокумент, ИскомыйТекст, ПолноеСовпадение = Истина, ВОднойСтроке = Истина, МодифицироватьОформлениеОбластей = Неопределено) Экспорт
	Найдено = НайтиПодрядИдущиеОбластиВСтрокеСОдинаковымТекстом(ТабДокумент, ИскомыйТекст, ПолноеСовпадение);
	Если Найдено = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли; 
	
	Если ВОднойСтроке = Истина Тогда
		ОбластьГде = ТабДокумент.Область(Найдено.ОбластьНачало.Верх,, Найдено.ОбластьКонец.Низ);
	ИначеЕсли ТипЗнч(ВОднойСтроке) = Тип("ОбластьЯчеекТабличногоДокумента") Тогда 	
		ОбластьГде = ВОднойСтроке;
	Иначе
		ОбластьГде = Неопределено;
	КонецЕсли; 
	
	Пока Найдено <> Неопределено Цикл
		Если Найдено.ОбластьНачало.Верх <>  Найдено.ОбластьКонец.Верх или Найдено.ОбластьНачало.Лево <> Найдено.ОбластьКонец.Лево или
			Найдено.ОбластьНачало.Низ <> Найдено.ОбластьКонец.Низ или Найдено.ОбластьНачало.Право <>  Найдено.ОбластьКонец.Право Тогда
			
			ОбластьОбъединение = ТабДокумент.Область(
				Найдено.ОбластьНачало.Верх, Найдено.ОбластьНачало.Лево,
				Найдено.ОбластьКонец.Низ, Найдено.ОбластьКонец.Право);
			
			ОбластьОбъединение.Разъединить();
			ОбластьОбъединение.Объединить();
			
			Если МодифицироватьОформлениеОбластей <> Неопределено Тогда
				Если МодифицироватьОформлениеОбластей.Свойство("ШрифтНаОсновании") Тогда
					ОбластьОбъединение.Шрифт = Новый Шрифт(ОбластьОбъединение.Шрифт,,,,
						ББР_КоллекцииКлиентСервер.СвойствоСтруктуры(МодифицироватьОформлениеОбластей.ШрифтНаОсновании, "Наклонный", Неопределено));
						
				КонецЕсли; 
			КонецЕсли; 
		Иначе
			ОбластьОбъединение = Найдено.ОбластьКонец;
		КонецЕсли;
		
		ОбластьС = ОбластьОбъединение;
		Найдено = НайтиПодрядИдущиеОбластиВСтрокеСОдинаковымТекстом(ТабДокумент, ИскомыйТекст, ПолноеСовпадение, ОбластьС, ОбластьГде);		
	КонецЦикла; 
	Возврат ОбластьОбъединение;
КонецФункции
 
Функция ОбъединитьСтрокиСОдинаковымЗначениемВКолонке(ТабДокумент, НомерКолонки, НомерСтроки1, НомерСтроки2) Экспорт
	ОблНачало = ТабДокумент.Область(НомерСтроки1, НомерКолонки);
	ТекОбласть = ОблНачало;
	ПредОбласть = ТекОбласть;
	НомерСтроки = НомерСтроки1;
	Пока НомерСтроки <= НомерСтроки2 Цикл
		ТекОбласть = ТабДокумент.Область(НомерСтроки, НомерКолонки);
		Если ТекОбласть.Текст <> ОблНачало.Текст Тогда
			Если ОблНачало.Низ < ПредОбласть.Низ  Тогда
				// объединяем область
				НоваяОбласть = ТабДокумент.Область(ОблНачало.Верх, НомерКолонки, ПредОбласть.Низ, НомерКолонки);
				НоваяОбласть.Разъединить();
				НоваяОбласть.Объединить();
			КонецЕсли;
			
			ОблНачало = ТекОбласть;
		КонецЕсли; 
		
		НомерСтроки = ТекОбласть.Низ+1;
		ПредОбласть = ТекОбласть;
	КонецЦикла; 	
	
	Если ОблНачало.Низ < ПредОбласть.Низ  Тогда
		// объединяем последнюю область
		НоваяОбласть = ТабДокумент.Область(ОблНачало.Верх, НомерКолонки, ПредОбласть.Низ, НомерКолонки);
		НоваяОбласть.Разъединить();
		НоваяОбласть.Объединить();
	КонецЕсли;
	
КонецФункции


Функция ПронумероватьСтолбцыТаблицы(ТабДокумент, знач НомерСтрокиСНомерами, знач НомерКолонкиС, знач НомерКолонкиПо, знач СтрокаИзКоторойКопировать = 0) Экспорт
	//Если НомерКолонкиПо = Неопределено Тогда
	//	НомерКолонкиПо = НомерКолонкиС;
	//	ОблСлед = ТабДокумент.Область(НомерСтрокиСНомерами, НомерКолонкиПо+1);
	//	Пока ОблСлед.Текст Цикл
	//	КонецЦикла; 
	//КонецЕсли; 
	
	Если СтрокаИзКоторойКопировать = 0 Тогда
		СтрокаИзКоторойКопировать = НомерСтрокиСНомерами+1;
	КонецЕсли; 
	
	ОбластьПриемник = ТабДокумент.Область(НомерСтрокиСНомерами, , НомерСтрокиСНомерами, );
	ОбластьИсточник = ТабДокумент.Область(СтрокаИзКоторойКопировать, , СтрокаИзКоторойКопировать, );
	ОбластьИсточникЯчейка = ТабДокумент.Область(СтрокаИзКоторойКопировать, НомерКолонкиС); 
	ТабДокумент.ВставитьОбласть(
		ОбластьИсточник, // исходная
		ОбластьПриемник, //приемник
		ТипСмещенияТабличногоДокумента.ПоВертикали,
		Ложь //ЗаполнятьПараметры
	);
	
	ОбластьПриемник.Разъединить();
	
	НомерКолонкиПП = 1;
	Для Кол=НомерКолонкиС По НомерКолонкиПо Цикл
		ТекОбласть = ТабДокумент.Область(НомерСтрокиСНомерами, Кол);
		ТекОбласть.Текст = Формат(НомерКолонкиПП, "ЧН=; ЧГ=");
		ТекОбласть.ГоризонтальноеПоложение = ГоризонтальноеПоложение.Центр;
		ТекОбласть.ВертикальноеПоложение = ВертикальноеПоложение.Центр;
		ТекОбласть.Обвести(ОбластьИсточникЯчейка.ГраницаСлева, ОбластьИсточникЯчейка.ГраницаСверху, ОбластьИсточникЯчейка.ГраницаСправа, ОбластьИсточникЯчейка.ГраницаСнизу);
		ТекОбласть.ЦветФона = ОбластьИсточникЯчейка.ЦветФона;
		ТекОбласть.ЦветРамки = ОбластьИсточникЯчейка.ЦветРамки;
		ТекОбласть.Шрифт = ОбластьИсточникЯчейка.Шрифт;
		НомерКолонкиПП = НомерКолонкиПП + 1;
	КонецЦикла; 
	
КонецФункции
  