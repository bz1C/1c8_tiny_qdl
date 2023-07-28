// Библиотека "быстрой" разработки на платформе 1С:Предприятие 8
// Модуль ББР_ПарсингКлиентСервер. Версия 1.2 от 28.07.2023
// Старое название: ББР_Парсинг. Версия 1.0 от 24.10.2018
// Назначение: Содержит функции парсинга строк
// Зависимости: ББР_СтроковыеКлиентСервер.
// Автор: Чернуль Александр Владимирович. E-mail: bzero@yandex.ru
// Лицензия на использование: Freeware.

//	Лексема = Новый Структура("Код, Содержимое, поз1, поз2, ЭтоЗакрывающаяЛексема", "", "", 0, 0, Ложь);
&НаКлиенте
Функция ПрочитатьСледующуюЛексему1CL(Лексема, ДлинаИсточника, СтрИсточник)
	режим = "";
	позНачала = Лексема.поз2+1;
	
	Лексема.ЭтоЗакрывающаяЛексема = Ложь;
	Лексема.Код="";
	Лексема.поз1=позНачала;
	
	Если позНачала > ДлинаИсточника Тогда
		Лексема.Код="";
		Лексема.поз2=ДлинаИсточника;
		Лексема.Содержимое = "";
		Возврат Ложь; 
	КонецЕсли;
	
	// читаем символы
	Для поз = позНачала По ДлинаИсточника Цикл
		КодСим = КодСимвола(СтрИсточник, поз);
				
		Если (режим = "" или режим = "незначащие") и ББР_СтроковыеКлиентСервер.ЭтоКодНезначащегоСимвола(КодСим) Тогда
			Режим = "незначащие";
			Продолжить;
		ИначеЕсли режим = "незначащие" Тогда
			// пробелы, табуляции и переводы строк закончились
			Лексема.поз2=поз-1;
			Прервать;
			
		ИначеЕсли режим = """" или режим = "" и КодСим = КодСимвола("""") Тогда
			Если КодСим = КодСимвола("""") Тогда
				Если режим = "" Тогда
					режим = """";
				ИначеЕсли поз < ДлинаИсточника и КодСимвола(СтрИсточник, поз+1) = КодСимвола("""") Тогда // сдвоенная кавычка внутри кавычки
					поз = поз+1;
				Иначе // закрывающая кавычка
					режим = "";
					Лексема.Код="СтроковаяКонстанта";
					Лексема.поз2=поз;
					Прервать; 
				КонецЕсли;
			Иначе
				; // символы-некавычки внутри кавычек
			КонецЕсли; 
		ИначеЕсли режим = "//" или режим = "" и КодСим = КодСимвола("/") и поз < ДлинаИсточника и КодСимвола(СтрИсточник, поз+1) = КодСимвола("/") Тогда
			Если режим = "" Тогда // начало комментария
				режим = "//";
			ИначеЕсли КодСим = КодСимвола(Символы.ПС) или КодСим = КодСимвола(Символы.ВК) или поз = ДлинаИсточника Тогда
				режим = "";
				Лексема.Код="//";
				Лексема.поз2=поз;
				Прервать;
			Иначе
				; // символы внутри комментария
			КонецЕсли;
		ИначеЕсли режим = "&" или режим = "" и КодСим = КодСимвола("&") Тогда
			Если режим = "" Тогда
				режим = "&";
			Иначе // после &
				Если ББР_СтроковыеКлиентСервер.ЭтоКодАнглийскойБуквы(КодСим) или ББР_СтроковыеКлиентСервер.ЭтоКодРусскойБуквы(КодСим) Тогда
					;
				Иначе
					Лексема.Код="&";
					Лексема.поз2=поз-1;
					Прервать;
				КонецЕсли; 
			КонецЕсли; 
		ИначеЕсли режим = "#" или режим = "" и КодСим = КодСимвола("#") Тогда
			Если режим = "" Тогда // символ #
				режим = "#";
			ИначеЕсли КодСим = КодСимвола(Символы.ПС) или КодСим = КодСимвола(Символы.ВК) или поз = ДлинаИсточника Тогда 
				// конец директивы препроцессора
				режим = "";
				Лексема.Код="#";
				Лексема.поз2=поз;
				Если НРег(Сред(СтрИсточник, Лексема.поз1+1, 5)) = "конец" или НРег(Сред(СтрИсточник, Лексема.поз1+1, 3)) = "end" Тогда
					Лексема.ЭтоЗакрывающаяЛексема = Истина;
				КонецЕсли;
			КонецЕсли;			
			                                                                                                                                     
		// Число (без знака, с .) [0-9]*[.]?[0-9]* Должна быть хотя бы одна цифра
		ИначеЕсли режим = "" и СтрНайти("1234567890.", Символ(КодСим)) <> 0 Тогда
			
			Если КодСим = КодСимвола(".") Тогда 
				БылаЦифра = Ложь;
				Этап = 2;
				позТочки = поз;
			Иначе
				БылаЦифра = Истина;
				Этап = 1;
				позТочки = 0;
			КонецЕсли;
			
			Пока поз <= ДлинаИсточника Цикл
				поз = поз+1;
				КодСим = КодСимвола(СтрИсточник, поз);
				Если ББР_СтроковыеКлиентСервер.ЭтоКодЦифры(КодСим) Тогда
					Если Этап = 2 Тогда
						Этап = 3;
					КонецЕсли; 
					БылаЦифра = Истина;
				ИначеЕсли КодСим = КодСимвола(".") Тогда
					Если Этап = 1 Тогда
						Этап = 2;
					Иначе
						// лексема кончилась
						поз = поз - 1;
						Прервать;
					КонецЕсли;
				Иначе
					// лексема кончилась
					поз = поз - 1;
					Прервать;
				КонецЕсли; 
			КонецЦикла; 
			
			Если не БылаЦифра Тогда
				Лексема.Код=".";
				Лексема.поз2=позТочки;
				Прервать;
			Иначе
				Лексема.Код="1";
				Лексема.поз2=поз;
				Прервать;
			КонецЕсли; 
			
		ИначеЕсли режим = "" и ББР_СтроковыеКлиентСервер.ЭтоКодАнглийскойБуквы(КодСим) или ББР_СтроковыеКлиентСервер.ЭтоКодРусскойБуквы(КодСим) или КодСим = КодСимвола("_") Тогда
			//Идентификатор буква, буквоцифра
			режим = "идентификатор";
			
			Пока поз <= ДлинаИсточника Цикл
				поз = поз+1;
				КодСим = КодСимвола(СтрИсточник,поз);
				Если ББР_СтроковыеКлиентСервер.ЭтоКодЦифры(КодСим) 
					или ББР_СтроковыеКлиентСервер.ЭтоКодАнглийскойБуквы(КодСим) 
					или ББР_СтроковыеКлиентСервер.ЭтоКодРусскойБуквы(КодСим) 
					или КодСим = КодСимвола("_") 
				Тогда
					;
				Иначе
					// лексема кончилась
					поз = поз - 1;
					Прервать;
				КонецЕсли; 
			КонецЦикла; 
			
			Лексема.Код="идентификатор";
			Лексема.поз2=поз;
			Прервать;
			// Ключевое слово - это тоже идентификатор. Их обрабатываем ниже
		
		// все остальное
		ИначеЕсли режим = "" и КодСим = КодСимвола("(") Тогда
			Лексема.Код="(";
			Лексема.поз2=поз;
			Прервать;
		ИначеЕсли режим = "" и КодСим = КодСимвола(")") Тогда
			Лексема.Код=")";
			Лексема.поз2=поз;
			Лексема.ЭтоЗакрывающаяЛексема = Истина;
			Прервать;		
		ИначеЕсли режим = "" и КодСим = КодСимвола("[") Тогда
			Лексема.Код="[";
			Лексема.поз2=поз;
			Прервать;
		ИначеЕсли режим = "" и КодСим = КодСимвола("]") Тогда
			Лексема.Код="]";
			Лексема.поз2=поз;
			Лексема.ЭтоЗакрывающаяЛексема = Истина;
			Прервать;		
		
		ИначеЕсли режим = "" и КодСим = КодСимвола("<") Тогда
			Лексема.Код="<";
			Лексема.поз2=поз;
			Прервать;
		ИначеЕсли режим = "" и КодСим = КодСимвола(">") Тогда
			Лексема.Код=">";
			Лексема.поз2=поз;
			Лексема.ЭтоЗакрывающаяЛексема = Истина;
			Прервать;		
		
		ИначеЕсли режим = "" и КодСим = КодСимвола("{") Тогда
			Лексема.Код="{";
			Лексема.поз2=поз;
			Прервать;
		ИначеЕсли режим = "" и КодСим = КодСимвола("}") Тогда
			Лексема.Код="}";
			Лексема.поз2=поз;
			Лексема.ЭтоЗакрывающаяЛексема = Истина;
			Прервать;		
			
		// прочие символы
		ИначеЕсли режим = "" Тогда
			Лексема.Код= Символ(КодСим);
			Лексема.поз2=поз;
			Прервать;
		Иначе
			Лексема.Код=режим;
			Лексема.поз2=поз-1;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Если Лексема.Код="идентификатор" Тогда
		ЗначениеЛексемы = НРег(ББР_СтроковыеКлиентСервер.СтрПодстрока(СтрИсточник, Лексема.поз1, Лексема.поз2));
		Если СтрНайти("/процедура/функция/",ЗначениеЛексемы) <> 0 Тогда
			Лексема.Код=ЗначениеЛексемы;
		ИначеЕсли СтрНайти("/конецпроцедуры/конецфункции/", ЗначениеЛексемы) <> 0 Тогда
			Лексема.Код=ЗначениеЛексемы;
			Лексема.ЭтоЗакрывающаяЛексема = Истина;
		КонецЕсли; 			
	КонецЕсли; 
	
	Лексема.Содержимое = Сред(СтрИсточник, Лексема.поз1, Лексема.поз2-Лексема.поз1+1);
	Возврат Лексема.поз2 > Лексема.поз1; 
КонецФункции

Функция РаспарситьURL(знач URL) Экспорт
	Результат = Новый Структура("Протокол, Сервер, Порт, Адрес");
	URL = СокрЛП(URL);
	УРЛ_Н = НРег(URL);
	
	Если СтрНачинаетсяС(УРЛ_Н, "http://") Тогда
		Результат.Протокол = "HTTP";
		ПозНачала = 8;
	ИначеЕсли СтрНачинаетсяС(УРЛ_Н, "https://") Тогда
		Результат.Протокол = "HTTPS";
		ПозНачала = 9;
	Иначе	
		Возврат Неопределено; 
	КонецЕсли; 
	
	МасЧастейАдреса = СтрРазделить(URL, "/", Истина);
	
	СерверПорт = МасЧастейАдреса[2];
	
	МасСерверПорт = СтрРазделить(СерверПорт, ":", Истина);
	
	Если МасСерверПорт.Количество() > 2 Тогда
		Возврат Неопределено; 
	КонецЕсли; 
	
	Если МасСерверПорт.Количество() = 2 Тогда
		Порт = ББР_СтроковыеКлиентСервер.ЧислоИзСтроки(МасСерверПорт[1], Неопределено);
		Если Порт = Неопределено Тогда
			Возврат Неопределено; 
		КонецЕсли;
		Результат.Порт = Порт;
	Иначе 
		Результат.Порт = Неопределено; 
	КонецЕсли;
	
	Результат.Сервер = МасСерверПорт[0];
	
	
	МасЧастейАдреса.Удалить(0); //http:
	МасЧастейАдреса.Удалить(0); //пустая строка
	МасЧастейАдреса.Удалить(0); //сервер:порт
	
	Результат.Адрес = "/"+СтрСоединить(МасЧастейАдреса, "/");
	
	Возврат Результат; 
КонецФункции

// Проверяет, является ли строка Стр идентификатором.
// Идентификатор может начинатьсяс русской или английской буквы, а также с любого символа, заданного в переменной СписокРазрешенныхРазделителейС1Символа
// Далее может следовать русская или английская буква, цифра,  а также любые символы, заданные в переменных СписокРазрешенныхРазделителейС1Символа и СписокРазрешенныхРазделителейСо2Символа
// Пустая строка не является идентификатором.
//ПАРАМЕТРЫ
//	Стр:Строка. Строка, проверка которой осуществляется.
//  СписокРазрешенныхРазделителейС1Символа:Строка.
//	СписокРазрешенныхРазделителейС1Символа:Строка.
//
//ВОЗВРАЩАЕТ
//	Булево. Истина - Стр является иднтификатором, иначе Ложь.
//
//Зависимости: ББР_СтроковыеКлиентСервер
Функция СтрокаЯвляетсяИдентификатором(Стр, СписокРазрешенныхРазделителейС1Символа="",СписокРазрешенныхРазделителейСо2Символа="") Экспорт
	ДлинаСтроки = СтрДлина(Стр);
	Если ДлинаСтроки=0 Тогда
		Возврат Ложь; 
	КонецЕсли;
	ПервыйСимволСтроки = КодСимвола(Стр,1);
	Если ББР_СтроковыеКлиентСервер.ЭтоКодАнглийскойБуквы(ПервыйСимволСтроки) или ББР_СтроковыеКлиентСервер.ЭтоКодРусскойБуквы(ПервыйСимволСтроки) или Найти(СписокРазрешенныхРазделителейС1Символа,Символ(ПервыйСимволСтроки)) <> 0 Тогда
		;
	Иначе
		Возврат Ложь; 
	КонецЕсли; 
	СписокРазрешенныхРазделителей=СписокРазрешенныхРазделителейСо2Символа+СписокРазрешенныхРазделителейС1Символа;
	Для сч=2 По ДлинаСтроки Цикл
		Симв = КодСимвола(Стр, сч);
		Если ББР_СтроковыеКлиентСервер.ЭтоКодАнглийскойБуквы(Симв) или ББР_СтроковыеКлиентСервер.ЭтоКодРусскойБуквы(Симв) или ББР_СтроковыеКлиентСервер.ЭтоКодЦифры(Симв) или Найти(СписокРазрешенныхРазделителей,Символ(Симв)) <> 0 Тогда
			;
		Иначе
			Возврат Ложь; 
		КонецЕсли; 
	КонецЦикла; 
	Возврат Истина; 
КонецФункции
