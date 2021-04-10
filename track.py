# -*- coding: utf-8 -*-

import os
import random


class RandomProductSearchSource:
    def __init__(self, track, params, **kwargs):
        if len(track.indices) == 1:
            default_index = track.indices[0].name
            if len(track.indices[0].types) == 1:
                default_type = track.indices[0].types[0].name
            else:
                default_type = None
        else:
            default_index = "_all"
            default_type = None

        self._index_name = params.get("index", default_index)
        self._type_name = params.get("type", default_type)
        self._cache = params.get("cache", False)
        self._params = params
        self.infinite = True

        cwd = os.path.dirname(__file__)
        with open(os.path.join(cwd, "products.txt"), "r") as ins:
            self.products = [line.strip() for line in ins.readlines()]

    def partition(self, partition_index, total_partitions):
        return self

    def params(self):
        return {
            "body": {
                "size": 10,
                "query": {
                    "bool": {
                        "must": [
                            {
                                "query_string": {
                                    "query": "name:*{}*".format(random.choice(self.products)[5:8])
                                }
                            }
                        ]
                    }
                },
                "aggs": {
                    "brands": {
                        "terms": {
                            "field": "brand.keyword",
                            "size": 30
                        },
                        "aggs": {
                            "price_percentile": {
                                "percentiles": {
                                    "field": "price"
                                }
                            }
                        }
                    },
                    "price_range": {
                        "histogram": {
                            "field": "price",
                            "interval": 5
                        }
                    },
                    "categories": {
                        "terms": {
                            "field": "category.keyword",
                            "size": 100
                        },
                        "aggs": {
                            "subcategories": {
                                "terms": {
                                    "field": "subcategory.keyword",
                                    "size": 100
                                }
                            }
                        }
                    }
                }
            },
            "index": self._index_name,
            "type": self._type_name,
            "cache": self._cache
        }


class RandomFilteredProductSearchSource:
    def __init__(self, track, params, **kwargs):
        if len(track.indices) == 1:
            default_index = track.indices[0].name
            if len(track.indices[0].types) == 1:
                default_type = track.indices[0].types[0].name
            else:
                default_type = None
        else:
            default_index = "_all"
            default_type = None

        self._index_name = params.get("index", default_index)
        self._type_name = params.get("type", default_type)
        self._cache = params.get("cache", False)
        self._params = params
        self.infinite = True

        cwd = os.path.dirname(__file__)
        with open(os.path.join(cwd, "products.txt"), "r") as ins:
            self.products = [line.strip() for line in ins.readlines()]

    def partition(self, partition_index, total_partitions):
        return self

    def params(self):
        price_range = 10000
        price_low = random.randint(0, 25) * price_range
        return {
            "body": {
                "size": 10,
                "query": {
                    "bool": {
                        "must": [
                            {
                                "query_string": {
                                    "query": "name:*{}*".format(random.choice(self.products)[5:8])
                                }
                            }
                        ]
                    }
                },
                "aggs": {
                    "brands": {
                        "terms": {
                            "field": "brand.keyword",
                            "size": 30
                        },
                        "aggs": {
                            "price_percentile": {
                                "percentiles": {
                                    "field": "price"
                                }
                            }
                        }
                    },
                    "price_range": {
                        "histogram": {
                            "field": "price",
                            "interval": 5
                        }
                    },
                    "categories": {
                        "terms": {
                            "field": "category.keyword",
                            "size": 100
                        },
                        "aggs": {
                            "subcategories": {
                                "terms": {
                                    "field": "subcategory.keyword",
                                    "size": 100
                                }
                            }
                        }
                    }
                }
            },
            "index": self._index_name,
            "type": self._type_name,
            "cache": self._cache
        }


def register(registry):
    registry.register_param_source(
        "products-param-source", RandomProductSearchSource)
    registry.register_param_source(
        "filtered-products-param-source", RandomFilteredProductSearchSource)
