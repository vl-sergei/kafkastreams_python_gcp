import datetime
from dateutil.parser import parse as parse_date
import faust
import logging


class ExpediaRecord(faust.Record):
    id: float
    date_time: str
    site_name: int
    posa_container: int
    user_location_country: int
    user_location_region: int
    user_location_city: int
    orig_destination_distance: float
    user_id: int
    is_mobile: int
    is_package: int
    channel: int
    srch_ci: str
    srch_co: str
    srch_adults_cnt: int
    srch_children_cnt: int
    srch_rm_cnt: int
    srch_destination_id: int
    srch_destination_type_id: int
    hotel_id: int


class ExpediaExtRecord(ExpediaRecord):
    stay_category: str


logger = logging.getLogger(__name__)
app = faust.App('kafkastreams', broker='kafka://kafka:9092')
source_topic = app.topic('expedia', value_type=ExpediaRecord)
destination_topic = app.topic('expedia_ext', value_type=ExpediaExtRecord)


def calculate_stay_category(message: ExpediaRecord) -> str:

    try:
        ci_date = parse_date(message.srch_co)
        co_date = parse_date(message.srch_ci)
        duration = (co_date - ci_date).days

    except:
        category = "Erroneous data"

    if not duration or duration <= 0:
        category = "Erroneous data"
    elif duration <= 4:
        category = "Short stay"
    elif duration <= 10:
        category = "Standard stay"
    elif duration <= 14:
        category = "Standard extended stay"
    else:
        category = "Long stay"

    return category


@app.agent(source_topic, sink=[destination_topic])
async def handle(messages):
    async for message in messages:
        if message is None:
            logger.info('No messages')
            continue

        # Transform your records here
        stay_category = calculate_stay_category(message)
        yield ExpediaExtRecord(**message.asdict(), stay_category=stay_category)

if __name__ == '__main__':
    app.main()